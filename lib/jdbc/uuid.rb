module JDBC
  class UUID
    def initialize(value)
      @value = value.to_s
    end

    def to_java
      java.util.UUID.from_string(value)
    end

    def valid?
      !UUID_REGEX.match(value).nil?
    end

    private

    attr_reader :value

    UUID_REGEX = /^[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i
    private_constant :UUID_REGEX
  end
end
