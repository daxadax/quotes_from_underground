module Persistence
  module Support
    module ValidationHelpers

      def raise_argument_error(reason, offender)
        klass       = self.class.name.split('::').last
        msg         = "Failure in #{klass}: "
        inspection  = "\n\nFailing argument:\n#{offender.inspect}"

        raise ArgumentError, msg + reason + inspection
      end

    end
  end

end