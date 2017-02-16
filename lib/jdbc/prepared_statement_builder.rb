module JDBC
  class PreparedStatementBuilder
    def initialize(connection:, sql:, bindings:)
      @connection = connection
      @jdbc_sql, @binding_values = SqlParser.new(sql: sql, bindings: bindings).parse
    end

    def build
      connection.prepare_statement(jdbc_sql).tap do |statement|
        binding_values.each_with_index do |(value, type), index|
          method_name, method_parameters = ParameterSetter.new(
            index: index,
            value: value,
            type: type
          ).build

          statement.public_send(method_name, *method_parameters)
        end
      end
    end

    private

    attr_reader :connection, :jdbc_sql, :binding_values

    class ParameterSetter
      def initialize(index:, value:, type:)
        @index = index
        @value = value
        @type = type
      end

      def build
        [method_name, method_parameters]
      end

      private

      attr_reader :index, :value, :type

      def method_name
        value.nil? ? :set_null : :set_object
      end

      def method_parameters
        if value.nil?
          [parameter_index, jdbc_type || java.sql.Types::NULL]
        else
          [parameter_index, value, jdbc_type].compact
        end
      end

      def parameter_index
        index + 1
      end

      def jdbc_type
        type ? java.sql.Types.const_get(type) : nil
      end
    end
    private_constant :ParameterSetter
  end
end
