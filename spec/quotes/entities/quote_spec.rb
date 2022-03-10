require 'spec_helper'

class QuoteSpec < MiniTest::Spec
  let(:added_by) { 23 }
  let(:content) { 'four score and...' }
  let(:publication) { build_publication(1) }
  let(:options) { {} }

  let(:quote) do
    Quotes::Entities::Quote.new(added_by, content, publication, options)
  end

  describe 'construction' do
    it 'can be built with two arguments and the publication it belongs to' do
      assert_equal 23, quote.added_by
      assert_equal 'four score and...', quote.content
      assert_equal publication.uid, quote.publication_uid
      assert_equal publication.author, quote.author
      assert_equal publication.title, quote.title
      assert_equal publication.publisher, quote.publisher
      assert_equal publication.year, quote.year
    end

    it "has sane defaults for non-required arguments" do
      assert_nil quote.uid
      assert_nil quote.page_number
      assert_empty quote.tags
      assert_empty quote.links
    end

    describe 'without' do

      describe 'publication' do
        describe 'needs to be a publication entity' do
          let(:publication) { "I'm not a publication entity" }

          it('fails') {assert_failure{quote}}
        end

        describe 'needs to be persisted' do
          let(:publication) { build_publication(nil) }

          it('fails') {assert_failure{quote}}
        end
      end

      describe 'added_by' do
        let(:added_by)  {nil}
        it('fails')   {assert_failure{quote}}
      end

      describe 'content' do
        let(:content) {nil}
        it('fails')   {assert_failure{quote}}
      end

    end

    describe 'can build all other attributes' do
      let(:tags) { ['tag_one', 'tag_two', 'tag_three'] }
      let(:options) do
        {
          :tags => tags,
          :page_number  => '356'
        }
      end

      it 'with an options hash' do
        assert_equal 3, quote.tags.size
        assert_equal '356',         quote.page_number
      end

      it "can be updated" do
        new_tags = %w[some new tags]
        quote.tags = quote.tags + new_tags

        assert_equal 6, quote.tags.count
      end
    end

  end

  describe 'tags' do
    let(:tags) { ['tag_one', '', 'tag_two'] }
    let(:options) do
      { :tags => tags }
    end

    it 'rejects empty tags' do
      assert_equal 2, quote.tags.count
      assert_equal ['tag_one', 'tag_two'], quote.tags
    end
  end

  describe "links" do
    let(:links) { [23, 666, 17] }
    let(:options) do
      {
        :links => links
      }
    end

    it "can be built with an options hash" do
      assert_equal 3, quote.links.size
    end

    describe "updating" do
      let(:new_link)      { 113 }
      let(:existing_link) { links.first }

      it "can add links" do
        quote.update_links(new_link)

        assert_equal 4, quote.links.size
        assert_includes quote.links, new_link
      end

      it "can remove links" do
        quote.update_links(existing_link)

        assert_equal 2, quote.links.size
        refute_includes quote.links, existing_link
      end
    end
  end

  describe 'updating' do
    let(:quote) { build_quote(:uid => 23) }
    let(:updates_hash) { Hash.new }
    let(:result) { quote.update(updates_hash) }

    it 'does not overwrite old values unless updates exist' do
      assert_equal quote.uid, result.uid
      assert_equal quote.added_by, result.added_by
      assert_equal quote.content, result.content
      assert_equal quote.page_number, result.page_number
      assert_equal quote.tags, result.tags
    end

    describe 'with updated values' do
      let(:updates_hash) do
        {
          :content => 'updated content',
          :page_number => 'xvii'
        }
      end

      it 'updates all given values' do
        assert_equal quote.uid, result.uid
        assert_equal quote.added_by, result.added_by
        assert_equal updates_hash[:content], result.content
        assert_equal updates_hash[:page_number], result.page_number
        assert_equal quote.tags, result.tags
      end
    end
  end
end
