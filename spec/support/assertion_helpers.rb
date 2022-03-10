module Support
  module AssertionHelpers
    def assert_failure(&block)
      assert_raises(ArgumentError, &block)
    end
  end
end
