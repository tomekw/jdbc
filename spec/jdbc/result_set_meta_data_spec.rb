require "spec_helper"

RSpec.describe JDBC::ResultSetMetaData do
  subject(:result_set_meta_data) { described_class.new(result_set: result_set) }

  let(:result_set) { double(meta_data: meta_data) }
  let(:meta_data) { double(column_count: 2) }

  let(:parsed_meta_data) do
    result_set_meta_data.parse.map do |c|
      [c.index, c.label, c.jdbc_type]
    end
  end

  let(:expected_meta_data) do
    [
      [1, :foo, :int4],
      [2, :bar, :varchar]
    ]
  end

  before do
    allow(meta_data).to receive(:get_column_label).and_return("foo", "bar")
    allow(meta_data).to receive(:get_column_type_name).and_return("int4", "varchar")
  end

  it "parses the meta data" do
    expect(parsed_meta_data).to eq expected_meta_data
  end
end
