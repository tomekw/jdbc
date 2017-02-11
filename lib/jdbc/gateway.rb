module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def query(sql, bindings = {})
      connection_pool.with_connection do |connection|
        begin
          statement = PreparedStatementBuilder.new(
            connection: connection,
            sql: sql,
            bindings: bindings
          ).build

          result_set = statement.execute_query

          ResultSetBuilder.new(result_set: result_set).build
        ensure
          statement.close
        end
      end
    end

    private

    attr_reader :connection_pool
  end
end
