class ApplicationBase < Sinatra::Application
  include Helpers::UseCaseCalling
  include Helpers::TemplateHelpers
  include Helpers::RouteHelpers

  configure do
    set :root, File.dirname(__FILE__)
    set :views, File.join(root, 'views')
  end

  configure :development do
    set :reload_templates, true
  end

  before do
    next if public_request?
    next if current_user

    redirect '/login'
  end

  def quotes
    quote_scope.all
  end

  def publications
    Publication.order(:publication_uid).all
  end

  def tags
    get_tags
  end

  def current_user
    return nil unless current_user_uid
    @curent_user ||= get_user(current_user_uid)
  end

  def current_user_owns?(record)
    return false unless current_user

    current_user.uid == record.added_by
  end

  def current_user_uid
    uid = session[:current_user_uid]
    return nil if uid.nil? || uid.to_s.empty?

    uid.to_s
  end

  def user_uid_param
    params[:uid].to_s
  end

  def handle_login_error(error)
    msg = "No user with that nickname is registered" if error == :user_not_found
    msg = "The password you entererd isn't right" if error == :auth_failure

    messages << msg
    redirect '/login'
  end

  def display_messages_and_reset_cache(&block)
    messages.each &block
    messages.clear
  end

  def messages
    session[:messages] ||= Array.new
  end

  def quote_by_uid(quote_uid)
    quote_scope.first(uid: quote_uid.to_i)
  end

  def publication_by_uid(publication_uid)
    Publication[publication_uid.to_i]
  end

  def publications_by_user(user_uid)
    Publication.where(added_by: user_uid).order(:publication_uid).all
  end

  def quotes_by_user(user_uid)
    quote_scope.where(added_by: user_uid).all
  end

  def favorite_quotes_for_user(user_uid)
    Quote.eager(:publication)
      .join(:favorites, quote_uid: :uid)
      .where(Sequel[:favorites][:user_uid] => user_uid)
      .order(Sequel[:quotes][:uid])
      .all
  end

  def quotes_by_publication(publication_uid)
    quote_scope.where(publication_uid: publication_uid.to_i).all
  end

  def quotes_by_tag(tag)
    tag = tag.to_s.strip.downcase
    quote_scope
      .join(:quote_tags, quote_uid: :uid)
      .where(Sequel[:quote_tags][:tag] => tag)
      .select_all(:quotes)
      .all
  end

  def similar_quotes(quote)
    Queries::SimilarQuotes.call(quote.uid)
  end

  def untagged_quotes_for_user(user_uid)
    quote_scope
      .where(added_by: user_uid)
      .where(Sequel.lit('cardinality(quotes.tags) = 0'))
      .all
  end

  def quotes_by_author(author)
    quote_scope
      .join(:publications, publication_uid: :publication_uid)
      .where(Sequel[:publications][:author] => author)
      .select_all(:quotes)
      .all
  end

  def quotes_by_title(title)
    quote_scope
      .join(:publications, publication_uid: :publication_uid)
      .where(Sequel[:publications][:title] => title)
      .select_all(:quotes)
      .all
  end

  def get_tags(user_uid = nil)
    tag_counts(user_uid).map { |row| row[:tag] }
  end

  def tag_counts(user_uid = nil)
    ds = DB[:quote_tags].group(Sequel[:quote_tags][:tag]).select(
      Sequel[:quote_tags][:tag].as(:tag),
      Sequel.function(:count, 1).as(:count)
    )
    if user_uid
      ds = ds.join(:quotes, uid: :quote_uid)
        .where(Sequel[:quotes][:added_by] => user_uid)
    end
    ds.order(Sequel.desc(:count)).all
  end

  def get_authors
    author_counts.map { |row| [row[:author], row[:count]] }
  end

  def get_titles
    title_counts.map { |row| [row[:title], row[:count]] }
  end

  def build_attributes(attributes)
    hash = Hash.new { |h, k| h[k] = 0}

    attributes.inject { |result, attribute| hash[attribute] += 1; result}
    hash.sort_by {|k, v| v}.reverse
  end

  def publication_uid_for(object)
    return object.publication_uid if object.is_a?(Quote)

    object.uid
  end

  def uid
    params[:uid].to_i
  end

  private

  def public_request?
    path = request.path_info

    return true if %w[/login /user/new].include?(path)
    return true if path.start_with?('/stylesheets/', '/javascript/', '/fonts/')

    false
  end

  def quote_scope
    Quote.eager(:publication).order(Sequel[:quotes][:uid])
  end

  def author_counts
    DB.from(:quotes)
      .join(:publications, publication_uid: :publication_uid)
      .group(Sequel[:publications][:author])
      .select(
        Sequel[:publications][:author].as(:author),
        Sequel.function(:count, 1).as(:count)
      )
      .order(Sequel.desc(:count))
      .all
  end

  def title_counts
    DB.from(:quotes)
      .join(:publications, publication_uid: :publication_uid)
      .group(Sequel[:publications][:title])
      .select(
        Sequel[:publications][:title].as(:title),
        Sequel.function(:count, 1).as(:count)
      )
      .order(Sequel.desc(:count))
      .all
  end
end

helpers do
  def display_page(location, locals = {})
    @form_page = !locals.delete(:form_page).nil?
    haml location.to_sym,
      layout: determine_layout,
      layout_options: { views: layout_views },
      locals: locals
  end

  def layout_views
    File.expand_path('views/layouts', settings.root)
  end

  def display_partial(location, locals = {})
    @form_page = !locals.delete(:form_page).nil?
    haml location.to_sym,
      :layout => false,
      :locals => locals
  end

  def determine_layout
    return :ajax if request.xhr?
    :default
  end

  def display_widget(locals = {})
    display_partial 'widget', locals
  end

  def link_to(url, text=url, opts={})
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end

  def truncate_content(quote)
    content = quote.content.split[0..3].join(" ")

    "[#{quote.title}] #{content}..."
  end

  def quote_to_json(quote)
    {
      :content => quote.content,
      :publication_uid => quote.publication_uid,
      :page_number => quote.page_number,
      :tags => quote.tags.join(', ')
    }.to_json
  end

  def show_author_for(object)
    author = object.author
    link_to "/author/#{author}", author unless params[:author]
  end

  def show_title_for(object)
    uid = publication_uid_for object
    title = object.title

    link_to "/publication/#{uid}", title
  end

  def determine_favorite_class(quote_uid)
    return ' ' unless current_user
    current_user.favorited?(quote_uid) ? 'favorite' : ''
  end

  def display_relevant_count_for(quotes)
    return "#{quotes.size} quotes tagged '#{params[:tag]}'" if params[:tag]
    return "#{quotes.size} quotes by #{params[:author]}" if params[:author]
    return "#{quotes.size} quotes from #{params[:title]}" if params[:title]

    "#{quotes.size} quotes"
  end

  def markdown(text)
    render_options = {
      filter_html: true,
      hard_wrap: true
    }
    renderer = Redcarpet::Render::HTML.new(render_options)

    extensions = {
      autolink: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      no_intra_emphasis: true,
      strikethrough: true,
      superscript: true
    }

    Redcarpet::Markdown.new(renderer, extensions).render(text).gsub("\n", "</br>")
  end
end
