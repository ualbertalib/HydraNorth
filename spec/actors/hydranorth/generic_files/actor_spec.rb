require 'spec_helper'

describe Hydranorth::GenericFile::Actor do
  include ActionDispatch::TestProcess
  
  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:generic_file) { FactoryGirl.create(:generic_file) }
  let(:actor) { Hydranorth::GenericFile::Actor.new(generic_file, user, {}) }
  let(:uploaded_file) { fixture_file_upload('/world.png','image/png') }
  let(:http_response) { double(body: "success: ark:/99999/fk4fn19h88") }
  let(:stub_response) { Ezid::CreateIdentifierResponse.new(http_response) }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Book" ]
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
    end
  end


  describe "#update_metadata" do
    it "should update year_created based on date_created" do
      expect(generic_file.date_created).to eq nil
      actor.update_metadata({date_created:'2012/01/01'}, 'open')
      expect(generic_file.date_created).to eq '2012/01/01'
      expect(generic_file.year_created).to eq '2012'
    end
  end

  describe "#destroy" do
    before do
      ezid = double('ezid')
      Hydranorth::EzidService.stub(:new) { ezid }
 
      allow(ezid).to receive(:delete).and_return(stub_response)
    end

    it "should delete generic file" do
      actor.destroy
      expect(GenericFile.exists?(generic_file.id)).to eq false
    end
  end

end
