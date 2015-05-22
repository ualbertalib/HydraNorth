require 'spec_helper'

describe Hydranorth::GenericFile::Actor do
  include ActionDispatch::TestProcess
  
  let(:user) { FactoryGirl.create(:user) }
  let(:generic_file) { FactoryGirl.create(:generic_file) }
  let(:actor) { Hydranorth::GenericFile::Actor.new(generic_file, user, {}) }
  let(:uploaded_file) { fixture_file_upload('/world.png','image/png') }

  describe "#update_metadata" do
    it "should update year_created based on date_created" do
      expect(generic_file.date_created).to eq nil
      actor.update_metadata({date_created:'2012/01/01'}, 'open')
      expect(generic_file.date_created).to eq '2012/01/01'
      expect(generic_file.year_created).to eq '2012'
    end
  end
end
