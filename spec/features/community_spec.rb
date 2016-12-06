require 'spec_helper'
require 'benchmark'

describe 'community', :type => :feature do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:jill) { FactoryGirl.create(:jill) }

  after :all do
    cleanup_jetty
  end

  describe 'browse' do
    let!(:community1) do
      Collection.create( title: 'Test Community 1') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = true
        c.is_official = true
        c.is_admin_set = false
      end
    end
    let!(:community2) do
      Collection.create( title: 'Test Community 2') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = true
        c.is_official = true
        c.is_admin_set = false
      end
    end

    let!(:collection1) do
      Collection.create( title: 'Test Collection 1') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = true
        c.is_admin_set = false
        c.belongsToCommunity = [community1.id]
      end
    end

    let!(:collection2) do
      Collection.create( title: 'Test Collection 2') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = true
        c.is_admin_set = false
        c.belongsToCommunity = [community1.id]
      end
    end

    let!(:collection3) do
      Collection.create( title: 'Test Collection 3') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = true
        c.is_admin_set = false
        c.belongsToCommunity = [community2.id]
      end
    end

    it 'should have all communities and collections' do
      expect( Benchmark.realtime { visit "/communities" }).to be < 5 # should render quickly
      expect(page).to have_content(community1)
      expect(page).to have_content(community2)
      expect(page).to have_content(collection1)
      expect(page).to have_content(collection2)
      expect(page).to have_content(collection3)
    end

  end

end
