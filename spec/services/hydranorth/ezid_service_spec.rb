require 'spec_helper'

describe Hydranorth::EzidService do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let!(:generic_file) do
    GenericFile.new do |f|
      f.id = @uuid
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Book" ]
      f.year_created = '2009'
      f.apply_depositor_metadata(user.user_key)
    end
  end
  let(:ezid) { Hydranorth::EzidService.new }

  before :all do
    @uuid = SecureRandom.uuid
  end

  after :all do
    cleanup_jetty
  end

  describe "create" do
    before do
      ark_identifier = ezid.create(generic_file)
    end

    it "should create ark" do
       ark_identifier = ezid.find(generic_file)
       expect(ark_identifier.id).to eq "ark:/99999/fk4#{generic_file.id}"
    end
  end

  describe "modify" do
    before do
      ark_identifier = ezid.modify(generic_file)
    end

    it "should have the correct title" do
       ark_identifier = ezid.find(generic_file)
       expect([ark_identifier.datacite_title]).to eq generic_file.title
    end
  end

end
