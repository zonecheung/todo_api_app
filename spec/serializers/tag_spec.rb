require 'rails_helper'

describe TagSerializer, 'json serialization output' do
  let(:tag) { FactoryBot.create(:tag, title: 'Potter') }
  let(:serializer) { TagSerializer.new(tag) }
  subject { ActiveModelSerializers::Adapter.create(serializer).to_json }

  it 'should have id in json output' do
    expect(subject).to be_json_eql("\"#{tag.id}\"").at_path('data/id')
  end

  it 'should have correct type in json output' do
    expect(subject).to be_json_eql('"tags"').at_path('data/type')
  end

  it 'should have correct title in json output' do
    expect(subject).to(
      be_json_eql('"Potter"').at_path('data/attributes/title')
    )
  end
end
