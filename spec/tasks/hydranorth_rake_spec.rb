require 'spec_helper'
require 'rake'
require 'fileutils'

describe "hydranorth.rake" do
  let(:past_date) { 2.days.ago }
  let!(:file) do
    FactoryGirl.build(:generic_file, title: ["tested embargo"]).tap do |work|
      work.apply_depositor_metadata('dittest@ualberta.ca')
      work.apply_embargo(past_date.to_s, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      work.save(validate:false)
    end
  end

  before do
    load File.expand_path("../../../lib/tasks/hydranorth.rake", __FILE__)
  end

  describe "hydranorth:remove_lapsed_embargoes" do

    before do
      Rake::Task.define_task(:environment)
      Rake::Task["hydranorth:remove_lapsed_embargoes"].invoke
    end

    after do
      Rake::Task["hydranorth:remove_lapsed_embargoes"].reenable
      file.delete
    end


    subject { GenericFile.find(file.id) }

    it "should clear the expired embargo" do
      expect(subject).not_to be_nil
      expect(subject.embargo_release_date).to be_nil
      expect(subject.embargo_history).not_to be_nil
      expect(subject.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
  end

end 
