require 'spec_helper'

describe GenericFilesController do
  let(:user) { FactoryGirl.find_or_create(:jill) }
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

    context "when updating metadata" do
      before do
        identifier = Ezid::Identifier.create(id: "ark:/99999/fk4#{generic_file.id}")
      end

      let(:update_message) { double('content update message') }
      before do
        allow(ContentUpdateEventJob).to receive(:new).with(generic_file.id, 'jilluser@example.com').and_return(update_message)
      end

      it "spawns a content update event job" do
        byebug
        expect(Sufia.queue).to receive(:push).with(update_message)
        post :update, id: generic_file, generic_file: { title: ['new_title'],
                                                        permissions_attributes: [{ type: 'person', name: 'archivist1', access: 'edit' }] }
        identifier = Ezid::Identifier.find("ark:/99999/fk4#{generic_file.id}")
        expect(identifier.datacite_title).to eq 'new_title'
      end

    end

  end

end
