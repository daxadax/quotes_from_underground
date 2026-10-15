module Queries
  class SimilarQuotes
    def self.call(quote_uid)
      new(quote_uid).call
    end

    def initialize(quote_uid)
      @uid = quote_uid.to_i
    end

    def call
      source = Quote[@uid]
      return [] unless source

      tags = source.tags || []
      dataset = base_dataset
      dataset = apply_similarity(dataset, tags) if tags.any?
      dataset.order(Sequel[:quotes][:uid]).all
    end

    private

    def base_dataset
      Quote.eager(:publication).exclude(uid: @uid)
    end

    def apply_similarity(dataset, tags)
      pg = Sequel.pg_array(tags)
      n = tags.size

      return dataset.where(Sequel.lit('quotes.tags @> ?', pg)) if n <= 3

      min = n <= 7 ? 0.5 : 0.3
      dataset.where(
        Sequel.lit(
          '(SELECT count(*) FROM unnest(?::text[]) t(tag) WHERE tag = ANY(quotes.tags))::float / ? > ?',
          pg, n, min
        )
      )
    end
  end
end
