module Support
  class FakeUsersBackend
    def initialize
      @memories = Hash.new
      @next_uid = 0
    end

    def reset
      @memories.clear
      @next_uid = 0
    end

    def insert(user)
      user[:uid] = next_uid

      @memories[user[:uid]] = user
      user[:uid]
    end

    def get(uid)
      @memories[uid]
    end

    def fetch(nickname)
      user = @memories.select do |uid, values|
        values[:nickname] == nickname
      end

      user.values.first
    end

    def all
      @memories.values
    end

    def update(user)
      @memories[user[:uid]] = user
      user[:uid]
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
