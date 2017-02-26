module JDBC
  module Coercions
    def identity
      @identity ||= ->(value) { value }
    end
    module_function :identity

    def to_s
      @to_s ||= ->(value) { value.to_s }
    end
    module_function :to_s

    def to_time
      @to_time ||= ->(value) { Time.parse(value.to_s) }
    end
    module_function :to_time
  end
end
