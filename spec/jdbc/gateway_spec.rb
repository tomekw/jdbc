require "spec_helper"

RSpec.describe JDBC::Gateway do
  subject(:gateway) { described_class.new(connection_pool: connection_pool) }

  describe "#query" do
    let(:seeded_records) do
      [
        {
          some_id: "a5142003-9453-4fed-ab90-f0bc47db6404",
          some_text: "Hello",
          some_number: 42,
          some_timestamp: DateTime.new(2017, 2, 1, 10, 0, 0),
          some_nullable_string: "World"
        },
        {
          some_id: "1f87e249-d90a-44c7-a986-51a77cdb01f4",
          some_text: "Foo",
          some_number: 1,
          some_timestamp: DateTime.new(2017, 2, 10, 14, 0, 0),
          some_nullable_string: nil
        }
      ]
    end

    let(:sql) { "SELECT * FROM things ORDER BY some_timestamp" }

    it "returns seeded records" do
      expect(gateway.query(sql)).to eq seeded_records
    end
  end
end
