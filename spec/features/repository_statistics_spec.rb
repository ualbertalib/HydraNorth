require 'spec_helper'

describe RepositoryStatisticsController, type: :feature do

  context '#facet_stats' do
    before do
      visit '/stats.json'
    end

    it 'should work' do
      expect(page.status_code).to be 200
    end

    it "should return valid JSON describing the repository's contents" do
      expect { @stats = JSON.parse(page.body)}.not_to raise_error

      expect(@stats).to have_key 'total_count'
      expect(@stats['total_count']).to be_kind_of String

      expect(@stats).to have_key 'facets'

      facets = @stats['facets']
      expect(facets.count).to be 5

      facets.each {|facet| expect(facet).to have_key 'indexLabel' }

      facets.each {|facet| expect(facet).to have_key 'y' }
      facets.each {|facet| expect(facet['y']).to be_kind_of Numeric }
    end
  end
end
