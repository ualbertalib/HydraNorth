require 'spec_helper'

describe GenericFilesController do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:http_response) { double(body: "success: ark:/99999/fk4fn19h88") }
  let(:stub_response) { Ezid::CreateIdentifierResponse.new(http_response) }

  before do
    allow(controller).to receive(:has_access?).and_return(true)
    sign_in user
    allow_any_instance_of(User).to receive(:groups).and_return([])
#    allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
    allow_any_instance_of(GenericFile).to receive(:characterize)
  end

  after :all do
    GenericFile.delete_all
  end

  describe "update" do
    let(:generic_file) do
      GenericFile.create do |gf|
        gf.apply_depositor_metadata(user)
      end
    end

    before do
      ezid = double('ezid')
      Hydranorth::EzidService.stub(:new) { ezid }

      allow(ezid).to receive(:modify).and_return(stub_response)
    end

    context "when updating metadata" do
      let(:update_message) { double('content update message') }
      before do
        allow(ContentUpdateEventJob).to receive(:new).with(generic_file.id, 'jilluser@example.com').and_return(update_message)
      end

      it "spawns a content update event job" do
        expect(Sufia.queue).to receive(:push).with(update_message)
        post :update, id: generic_file, generic_file: { title: ['new_title'],
                                                        permissions_attributes: [{ type: 'person', name: 'archivist1', access: 'edit' }] }
      end

      it "modifies ezid metadata" do
        ark_identifier = Ezid::Identifier.create(id: "ark:/99999/fk49999999")
        ark_identifier = Ezid::Identifier.find(ark_identifier.id)
        unless ark_identifier.nil?
          ark_identifier.datacite_title = 'new_title'
          ark_identifier.save
        end

        expect(ark_identifier.reload.datacite_title).to eq 'new_title'
        ark_identifier.delete
      end
    end

  end

end
