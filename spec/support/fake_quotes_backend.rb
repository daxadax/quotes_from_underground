module Support
  class FakeQuotesBackend

    def initialize(publications_backend)
      @publications_backend = publications_backend
      @memories = Hash.new
      @next_uid = 0
    end

    def reset
      @memories.clear
      @next_uid = 0
    end

    def insert(object)
      object[:uid] = next_uid

      @memories[object[:uid]] = object
      object[:uid]
    end

    def get(uid)
      result = @memories[uid]
      return nil if result.nil?

      publication_for_result = @publications_backend.get(result[:publication_uid])
      result.merge(publication_for_result)
    end

    def all
      @memories.values.map do |quote|
        get quote[:uid]
      end
    end

    def update(object)
      @memories[object[:uid]] = object
      object[:uid]
    end

    def delete(uid)
      @memories.delete(uid)
    end

    private

    def next_uid
      @next_uid += 1
    end

  end
end
