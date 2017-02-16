module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def query(sql, bindings = {})
      connection_pool.with_connection do |conn|
        begin
          jdbc_sql, binding_values = SqlParser.new(sql: sql, bindings: bindings).parse

          statement =
            PreparedStatementBuilder.for_query(connection: conn, jdbc_sql: jdbc_sql, binding_values: binding_values)

          result_set = statement.execute_query

          ResultSetTransformer.new(result_set: result_set).transform
        ensure
          result_set&.close
          statement&.close
        end
      end
    end

    private

    attr_reader :connection_pool
  end
end
