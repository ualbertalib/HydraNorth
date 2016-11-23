require 'spec_helper'

describe "hydranorth:remove_lapsed_embargoes", type: :task do
  before(:all) do
    load_rake_environment('tasks/hydranorth')
  end

  let(:past_date) { 2.days.ago }
  let!(:file) do
    FactoryGirl.build(:generic_file, title: ["tested embargo"], embargo_release_date: past_date.to_s, visibility_after_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, visibility_during_embargo: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) do |work|
      work.apply_depositor_metadata('dittest@ualberta.ca')
      work.save(validate: false)
    end
  end

  after(:each) do
    GenericFile.delete_all
  end

  it "clears the expired embargo" do
    run_rake_task('hydranorth:remove_lapsed_embargoes')
    object = GenericFile.find(file.id)
    expect(object).not_to be_nil
    expect(object.embargo_release_date).to be_nil
    expect(object.embargo_history).not_to be_empty
    expect(object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
