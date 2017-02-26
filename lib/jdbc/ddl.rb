module JDBC
  class DDL < Action
    def run
      result_set.zero?
    end

    private

    def result_set
      @result_set ||= statement.execute_update
    end

    def statement
      @statement ||= PreparedStatementBuilder.for_query(
        connection: connection,
        jdbc_sql: jdbc_sql,
        binding_values: binding_values
      )
    end
  end
end
