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

    def to_date_time
      @to_date_time ||= ->(value) { DateTime.parse(value.to_s) }
    end
    module_function :to_date_time
  end
end
