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

describe Tag, 'partial_match' do
  let!(:tag1) { FactoryBot.create(:tag, title: 'foo') }
  let!(:tag2) { FactoryBot.create(:tag, title: 'boo') }
  let!(:tag3) { FactoryBot.create(:tag, title: 'baz') }

  it 'should return correct partial matches from the center of text' do
    tags = Tag.partial_match('oo')
    expect(tags).to include(tag1)
    expect(tags).to include(tag2)
    expect(tags).not_to include(tag3)
  end

  it 'should return correct case insensitive partial matches from the center of text' do
    tags = Tag.partial_match('OO')
    expect(tags).to include(tag1)
    expect(tags).to include(tag2)
    expect(tags).not_to include(tag3)
  end

  it 'should return correct partial matches from the beginning of text' do
    tags = Tag.partial_match('b')
    expect(tags).not_to include(tag1)
    expect(tags).to include(tag2)
    expect(tags).to include(tag3)
  end

  it 'should return everything if the term is nil' do
    tags = Tag.partial_match(nil)
    expect(tags).to include(tag1)
    expect(tags).to include(tag2)
    expect(tags).to include(tag3)
  end
end