module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def query(sql, bindings = {})
      connection_pool.with_connection do |conn|
        begin
          statement = PreparedStatementBuilder.new(connection: conn, sql: sql, bindings: bindings).build

          result_set = statement.execute_query

          ResultSetTransformer.new(result_set: result_set).transform
        ensure
          statement.close
        end
      end
    end

    private

    attr_reader :connection_pool
  end
end
