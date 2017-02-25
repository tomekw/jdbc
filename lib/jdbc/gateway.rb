module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    def command(sql, bindings = {})
      connection_pool.with_connection do |connection|
        Command.new(connection: connection, sql: sql, bindings: bindings).run
      end
    end

    def query(sql, bindings = {})
      connection_pool.with_connection do |connection|
        Query.new(connection: connection, sql: sql, bindings: bindings).run
      end
    end

    private

    attr_reader :connection_pool
  end
end
