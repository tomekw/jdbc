module JDBC
  class ResultSetBuilder
    def initialize(result_set:)
      @result_set = result_set
    end

    def build
      [].tap do |results|
        while result_set.next
          results << meta_data.each_with_object({}) do |column, record|
            record[column.label] =
              column.coerce_proc.call(result_set.get_object(column.index))
          end
        end
      end
    end

    private

    attr_reader :result_set

    def meta_data
      @meta_data ||= ResultSetMetaData.new(result_set: result_set).parse
    end
  end
end
