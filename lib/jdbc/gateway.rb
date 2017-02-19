module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def command(sql, bindings = {}, conn = datasource.connection)
      jdbc_sql, binding_values = SqlParser.new(sql: sql, bindings: bindings).parse

      statement =
        PreparedStatementBuilder.for_command(connection: conn, jdbc_sql: jdbc_sql, binding_values: binding_values)

      statement.execute_update

      result_set = statement.get_generated_keys

      ResultSetTransformer.new(result_set: result_set).transform
    ensure
      result_set&.close
      statement&.close
      conn&.close
    end

    def query(sql, bindings = {}, conn = datasource.connection)
      jdbc_sql, binding_values = SqlParser.new(sql: sql, bindings: bindings).parse

      statement =
        PreparedStatementBuilder.for_query(connection: conn, jdbc_sql: jdbc_sql, binding_values: binding_values)

      result_set = statement.execute_query

      ResultSetTransformer.new(result_set: result_set).transform
    ensure
      result_set&.close
      statement&.close
      conn&.close
    end

    private

    attr_reader :connection_pool

    def datasource
      @datasource ||= connection_pool.open
    end
  end
end
