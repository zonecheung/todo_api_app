require 'rails_helper'

describe Tag, 'validations', type: :model do
  subject { FactoryBot.build(:tag) }

  it { is_expected.to be_valid }

  context 'when the title is blank' do
    before(:each) do
      subject.title = ''
    end

    it { is_expected.not_to be_valid }
  end

  context 'when there\'s another tag' do
    let!(:another_tag) { FactoryBot.create(:tag, title: 'Potter') }

    it { is_expected.to be_valid }

    context 'when the titles are the same' do
      before(:each) do
        subject.title = 'Potter'
      end

      it { is_expected.not_to be_valid }
    end
  end
end

describe Tag, 'json serialization output' do
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
