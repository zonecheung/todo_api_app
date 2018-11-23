require 'rails_helper'

describe TaskSerializer, 'json serialization output' do
  let(:task) do
    FactoryBot.create(:task, title: 'Potter', tags: %w[hermione granger])
  end
  let(:serializer) { TaskSerializer.new(task) }
  subject { ActiveModelSerializers::Adapter.create(serializer).to_json }

  it 'should have id in json output' do
    expect(subject).to be_json_eql("\"#{task.id}\"").at_path('data/id')
  end

  it 'should have correct type in json output' do
    expect(subject).to be_json_eql('"tasks"').at_path('data/type')
  end

  it 'should have correct title in json output' do
    expect(subject).to(
      be_json_eql('"Potter"').at_path('data/attributes/title')
    )
  end

  it 'should have correct number of tags' do
    expect(subject).to have_json_size(2).at_path('data/relationships/tags/data')
  end

  it 'should have correct type in tags relationship' do
    expect(subject).to(
      be_json_eql('"tags"').at_path('data/relationships/tags/data/0/type')
    )
    expect(subject).to(
      be_json_eql('"tags"').at_path('data/relationships/tags/data/1/type')
    )
  end
end
