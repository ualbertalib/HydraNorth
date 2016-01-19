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

  let!(:community) do
    Collection.new.tap do |c|
      c.apply_depositor_metadata user
      c.title = "test community"
      c.is_community = true
      c.save!
    end
  end

  let!(:collection) do
    Collection.new.tap do |c|
      c.apply_depositor_metadata user
      c.title = "test collection"
      c.belongsToCommunity = [community.id]
      c.save!
    end
  end
  
  let!(:community2) do
    Collection.new.tap do |c|
      c.apply_depositor_metadata user
      c.title = "test community2"
      c.is_community = true
      c.save!
    end
  end

  let!(:collection2) do
    Collection.new.tap do |c|
      c.apply_depositor_metadata user
      c.title = "test collection2"
      c.belongsToCommunity = [community2.id]
      c.save!
    end
  end


  describe "#run" do
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] }}
    let(:trid) { { file.id => 'TR-123', file2.id => 'TR-456' }}
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        subject: [''], date_created: '2012/01/01', belongsToCommunity: [community.id, community2.id], 
        hasCollectionId:[collection.id, collection2.id] }.with_indifferent_access
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

      it "should add to multiple collections" do
        expect(collection.reload.member_ids).to include file.id
        expect(collection.reload.member_ids).to include file2.id
        expect(collection2.reload.member_ids).to include file.id
        expect(collection2.reload.member_ids).to include file2.id
      end

      it "add hasCollection titles to both files" do
        expect(file.reload.hasCollection).to include "test collection"
        expect(file.reload.hasCollection).to include "test collection2"
        expect(file2.reload.hasCollection).to include "test collection"
        expect(file2.reload.hasCollection).to include "test collection2"
      end

      it "save belongsToCommunity and hasCollectionId correctly" do
        expect(file.reload.hasCollectionId).to include collection.id
        expect(file.reload.hasCollectionId).to include collection2.id
        expect(file.reload.belongsToCommunity).to include community.id
        expect(file.reload.belongsToCommunity).to include community2.id
        expect(file2.reload.hasCollectionId).to include collection.id
        expect(file2.reload.hasCollectionId).to include collection2.id
        expect(file2.reload.belongsToCommunity).to include community.id
        expect(file2.reload.belongsToCommunity).to include community2.id
      end
 
      it "should have an ark identifier" do
        expect(file.reload.ark_created).to eq "true"
        expect(file.reload.ark_id).to eq "ark:/99999/fk4#{file.id}"
      end
     
      it "ark should resolve" do
        uri = URI"http://n2t.net/ark:/99999/fk4#{file.id}"

        request = Net::HTTP.new uri.host
        response= request.request_head uri.path
        expect(response.code.to_i).to eq 302 
      end
    end
  end

  describe "embargo visibility" do 
    let(:title) { { file.id => ['File One'], file2.id => ['File Two'] }}
    let(:trid) { { file.id => 'TR-123', file2.id => 'TR-456' }}
    let(:metadata) do
      { read_groups_string: '', read_users_string: 'archivist1, archivist2',
        subject: [''], date_created: '2012/01/01', belongsToCommunity: [community.id, community2.id], 
        hasCollectionId:[collection.id, collection2.id] }.with_indifferent_access
    end
  
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
    let(:ser) { nil }
    let(:job) { BatchUpdateJob.new(user.user_key, batch.id, title, trid, ser, metadata, visibility, '2112-01-01', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }

    before do
      allow(Sufia.queue).to receive(:push)
    end

    it 'should work' do
      expect {job.run}.not_to raise_error
      expect(file.reload.under_embargo?).to be true
    end

  end

end
