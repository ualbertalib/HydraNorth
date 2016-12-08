require 'spec_helper'

describe 'analytics', :type => :feature, js: true do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file1) do
    GenericFile.new.tap do |f|
      f.title = ['little_file-1.txt']
      f.creator = ['little_file-1.txt_creator']
      f.resource_type = ["Thesis" ]
      f.read_groups = ['public']
      f.aasm_state = 'excluded'
      f.apply_depositor_metadata(user.user_key)
      f.add_file(File.open('lib/tasks/migration/stats/ga_stats.txt'), path: 'era1stats', original_name: 'ga_stats.txt', mime_type: 'text/xml')
      f.save!
    end
  end

  let!(:file2) do
    GenericFile.new.tap do |f|
      f.title = ['little_file-2.txt']
      f.creator = ['little_file-2.txt_creator']
      f.resource_type = ["Thesis" ]
      f.read_groups = ['public']
      f.aasm_state = 'excluded'
      f.apply_depositor_metadata(user.user_key)
      f.add_file(File.open('lib/tasks/migration/stats/ga_stats_2.txt'), path: 'era1stats', original_name: 'ga_stats_2.txt', mime_type: 'text/xml')
      f.save!
    end
  end

  after :all do
    cleanup_jetty
  end

  it "contains the correct number of downloads" do
    visit "/files/#{file1.id}/stats"
    expect(page).to have_content('downloaded 4 times')
  end

  it "contains the correct number of downloads" do
    visit "/files/#{file2.id}/stats"
    expect(page).to have_content('viewed* 121 times and downloaded 566 times')
  end

end
