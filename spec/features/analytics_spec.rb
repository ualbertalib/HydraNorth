require 'spec_helper'

describe 'analytics', :type => :feature, :js => true do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Thesis" ]
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.add_file(File.open('lib/tasks/migration/stats/ga_stats.txt'), path: 'era1stats', original_name: 'ga_stats.txt', mime_type: 'text/xml')
      f.save!
    end
  end

#  after :all do
#    cleanup_jetty
#  end

  before do 
    visit "/files/#{file.id}/stats"
  end

  it "contains the correct number of downloads" do
    expect(page).to have_content('4 downloads')
  end
  
end
