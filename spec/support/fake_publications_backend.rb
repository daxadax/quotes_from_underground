module Support
  class FakePublicationsBackend
    def initialize
      @memories = Hash.new
      @next_uid = 0
    end

    def reset
      @memories.clear
      @next_uid = 0
    end

    def insert(object)
      object[:publication_uid] = next_uid

      @memories[object[:publication_uid]] = object
      object[:publication_uid]
    end

    def get(uid)
      @memories[uid]
    end

    def all
      @memories.values
    end

    def update(object)
      @memories[object[:publication_uid]] = object
      object[:publication_uid]
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
