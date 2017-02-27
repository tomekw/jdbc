module JDBC
  class Gateway
    def initialize(connection_pool:)
      @connection_pool = connection_pool
    end

    %w[Command DDL Query].each do |action_name|
      define_method(action_name.downcase) do |sql, bindings = {}|
        connection_pool.with_connection do |connection|
          JDBC
            .const_get(action_name)
            .new(connection: connection, sql: sql, bindings: bindings)
            .run
        end
      end
    end

    private

    attr_reader :connection_pool
  end
end
