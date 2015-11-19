require 'spec_helper'
require 'support/shared_contexts/rake'

describe "hydranorth:remove_lapsed_embargoes" do
  include_context "rake"
  let(:past_date) { 2.days.ago }
  let!(:file) do
    FactoryGirl.build(:generic_file, title: ["tested embargo"], embargo_release_date: past_date.to_s, visibility_after_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, visibility_during_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE).tap do |work|
      work.apply_depositor_metadata('dittest@ualberta.ca')
      work.save(validate: false)
    end
  end
  its(:prerequisites) { should include("environment") }

  after do
    GenericFile.delete_all
  end

  it "clears the expired embargo" do
    subject.invoke
    object = GenericFile.find(file.id)
    expect(object).not_to be_nil
    expect(object.embargo_release_date).to be_nil
    expect(object.embargo_history).not_to be_empty
    expect(object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
