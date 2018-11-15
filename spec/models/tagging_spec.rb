require 'rails_helper'

describe Tagging, 'validations', type: :model do
  subject { FactoryBot.build(:tagging) }

  it { is_expected.to be_valid }

  context 'when tag_id is nil' do
    before(:each) do
      subject.tag_id = nil
    end

    it { is_expected.not_to be_valid }
  end

  context 'when there\'s another tagging' do
    let!(:another_tagging) { FactoryBot.create(:tagging) }

    it { is_expected.to be_valid }

    context 'when the task_id is the same' do
      before(:each) do
        subject.task_id = another_tagging.task_id
      end

      it { is_expected.to be_valid }

      context 'when the tag_id is also the same' do
        before(:each) do
          subject.tag_id = another_tagging.tag_id
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
