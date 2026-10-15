WriteResult = Struct.new(:error, :uid, keyword_init: true) do
  def self.ok(uid = nil)
    new(error: nil, uid: uid)
  end

  def self.fail(error)
    new(error: error, uid: nil)
  end
end
