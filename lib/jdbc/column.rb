module JDBC
  class Column
    attr_reader :index, :label

    def initialize(index:, label:, jdbc_type:)
      @index = index
      @label = label
      @jdbc_type = jdbc_type
    end

    def coerce_proc
      Coercions.public_send(COERCIONS_MAP.fetch(jdbc_type, :identity))
    end

    private

    attr_reader :jdbc_type

    COERCIONS_MAP = {
      uuid: :to_s,
      text: :identity,
      int4: :identity,
      timestamp: :to_date_time,
      varchar: :identity
    }.freeze
    private_constant :COERCIONS_MAP
  end
end
