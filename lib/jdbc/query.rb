module JDBC
  class Query < Action
    private

    def result_set
      @result_set ||= statement.execute_query
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
