require 'rails_helper'

describe Task, 'validations', type: :model do
  subject { FactoryBot.build(:task) }

  it { is_expected.to be_valid }

  context 'when the title is blank' do
    before(:each) do
      subject.title = ''
    end

    it { is_expected.not_to be_valid }
  end
end

describe Task, 'tags', type: :model do
  context 'when created with tags' do
    subject { FactoryBot.create(:task, tags: %w[harry potter]) }

    it 'should have two taggings' do
      expect(subject.taggings.count).to eql(2)
    end

    it 'should have two tags' do
      expect(subject.tags.count).to eql(2)
    end

    it 'should have correct title in tags' do
      tag_names = subject.tags.pluck(:title)
      expect(tag_names).to include('harry')
      expect(tag_names).to include('potter')
    end

    context 'when updated without tags' do
      before(:each) do
        subject.update_attributes!(title: 'Halfblood Prince')
        subject.reload
      end

      it 'should still have two taggings' do
        expect(subject.taggings.count).to eql(2)
      end

      it 'should still have two tags' do
        expect(subject.tags.count).to eql(2)
      end

      it 'should still have the same tags' do
        tag_names = subject.tags.pluck(:title)
        expect(tag_names).to include('harry')
        expect(tag_names).to include('potter')
      end
    end

    context 'when updated with blank tags' do
      before(:each) do
        subject.update_attributes!(tags: [])
        subject.reload
      end

      it 'should have no taggings' do
        expect(subject.taggings.count).to eql(0)
      end
    end

    context 'when updated with all new tags' do
      before(:each) do
        subject.update_attributes!(tags: %w[hermione granger])
        subject.reload
      end

      it 'should have two taggings' do
        expect(subject.taggings.count).to eql(2)
      end

      it 'should have two tags' do
        expect(subject.tags.count).to eql(2)
      end

      it 'should have correct title in tags' do
        tag_names = subject.tags.pluck(:title)
        expect(tag_names).to include('hermione')
        expect(tag_names).to include('granger')
      end

      it 'should not remove the old tags in the table' do
        expect(Tag.where(title: 'harry')).to be_exists
        expect(Tag.where(title: 'potter')).to be_exists
      end
    end
  end
end

describe Task, 'json serialization output' do
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
