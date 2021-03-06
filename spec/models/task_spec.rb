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

    it 'shoud have correct taggings and tags' do
      expect(subject.tags.pluck(:title)).to eql(%w[harry potter])
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

    context 'when destroyed' do
      let!(:tagging_ids) { subject.taggings.pluck(:id) }
      let!(:tag_ids) { subject.tags.pluck(:id) }

      before(:each) do
        subject.destroy
      end

      it 'should destroy associated taggings' do
        tagging_ids.each do |id|
          expect(Tagging.exists?(id)).to be(false)
        end
      end

      it 'should not destroy the tags' do
        tag_ids.each do |id|
          expect(Tag.exists?(id)).to be(true)
        end
      end
    end
  end
end

describe Task, 'with duplicated tags' do
  subject { FactoryBot.create(:task, tags: %w[harry potter]) }
  let!(:tag1) { subject.tags[0] }
  let!(:tag2) { subject.tags[1] }

  before do
    expect { subject.taggings[0].update_column(:tag_id, tag2.id) }.to raise_error
    subject.reload
  end

  it 'should have same tag_id in both taggings' do
    expect(subject.taggings[0].tag_id).to eql(tag1.id)
    expect(subject.taggings[1].tag_id).to eql(tag2.id)
  end
end