module JDBC
  class PreparedStatementBuilder
    def initialize(connection:, sql:, bindings:)
      @connection = connection
      @jdbc_sql, @binding_values = SqlParser.new(sql: sql, bindings: bindings).parse
    end

    def build
      connection.prepare_statement(jdbc_sql).tap do |statement|
        binding_values.each do |value|
        end
      end
    end

    private

    attr_reader :connection, :jdbc_sql, :binding_values
  end
end
