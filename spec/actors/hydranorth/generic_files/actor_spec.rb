require 'spec_helper'

describe Hydranorth::GenericFile::Actor do
  let(:user) { FactoryGirl.build(:user) }
  let(:generic_file) { FactoryGirl.build(:generic_file) }
  let(:actor) { Hydranorth::GenericFile::Actor.new(generic_file, user, {}) }
  let(:uploaded_file) { ActionDispatch::TestProcess.fixture_file_upload('/world.png','image/png') }

  describe "#update_metadata" do
    it "should update year_created based on date_created" do
      expect(generic_file.date_created).to eq nil
      actor.update_metadata({date_created:'2012/01/01'}, 'open')
      expect(generic_file.date_created).to eq '2012/01/01'
      expect(generic_file.year_created).to eq '2012'
    end
  end
end
