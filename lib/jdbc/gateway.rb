module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def query(sql)
      connection_pool.with_connection do |connection|
        result_set = connection.prepare_statement(sql).execute_query

        ResultSetBuilder.new(result_set: result_set).build
      end
    end

    private

    attr_reader :connection_pool
  end
end
