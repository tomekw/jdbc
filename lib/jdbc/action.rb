module JDBC
  class Action
    def initialize(connection:, sql:, bindings:)
      @connection = connection
      @sql = sql
      @bindings = bindings
    end

    def run
      ResultSetTransformer.new(result_set: result_set).transform
    ensure
      result_set&.close
      statement&.close
    end

    private

    attr_reader :connection, :sql, :bindings

    def parsed_sql
      @parsed_sql ||= SqlParser.new(sql: sql, bindings: bindings).parse
    end

    def jdbc_sql
      parsed_sql.first
    end

    def binding_values
      parsed_sql.last
    end
  end
end
