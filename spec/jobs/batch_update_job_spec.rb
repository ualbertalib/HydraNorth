require 'spec_helper'

describe BatchUpdateJob do

  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:batch) { Batch.create }

  let!(:file) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  let!(:file2) do
    GenericFile.new(batch: batch) do |file|
      file.apply_depositor_metadata(user)
      file.save!
    end
  end

  describe "#run" do
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] }}
    let(:trid) { { file.id => 'TR-123', file2.id => 'TR-456' }}
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        subject: [''], date_created: '2012/01/01' }.with_indifferent_access
    end

    let(:visibility) { nil }
    let(:ser) { nil }
    let(:job) { BatchUpdateJob.new(user.user_key, batch.id, title, trid, ser, metadata, visibility) }

    describe "updates metadata" do
      before do
        allow(Sufia.queue).to receive(:push)
        job.run
      end

      it "should update the trid" do
        expect(file.reload.trid).to eq 'TR-123'
      end
 
      it "should update the year_created based on date_created" do
        expect(file.reload.year_created).to eq '2012'
      end
    end
  end
end
