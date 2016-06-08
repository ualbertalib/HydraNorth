require 'spec_helper'

describe 'download link', :type => :feature do

  let(:user) { FactoryGirl.find_or_create :jill }

  after(:all) do
    GenericFile.destroy_all
  end

  describe 'when pass id to download_path' do
    let!(:gf) do
      GenericFile.new.tap do |f|
        f.label = 'myfile.txt' 
        f.apply_depositor_metadata user
        f.save!
      end
    end

    it 'should return path with label' do
      expect(download_path(gf.id)).to eq "/files/#{gf.id}/#{gf.label}"
    end
  end
end
