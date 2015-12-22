require 'spec_helper'

describe RepositoryStatisticsController, type: :feature do

  context '#facet_stats' do
    before do
      allow(ActiveFedora::SolrService.instance.conn).to receive(:get) { JSON.parse("{\"responseHeader\":{\"status\":0,\"QTime\":7,\"params\":{\"q\":\"active_fedora_model_ssi:\\\"GenericFile\\\"\",\"facet.field\":\"resource_type_sim\",\"rows\":\"0\",\"wt\":\"json\",\"facet\":\"true\"}},\"response\":{\"numFound\":38184,\"start\":0,\"maxScore\":2.328004,\"docs\":[]},\"facet_counts\":{\"facet_queries\":{},\"facet_fields\":{\"resource_type_sim\":[\"Thesis\",18261,\"Report\",9452,\"Image\",5521,\"Journal Article (Published)\",2171,\"Research Material\",609,\"Conference/workshop Presentation\",381,\"Dataset\",316,\"Computing Science Technical Report\",255,\"Review\",215,\"Structural Engineering Report\",187]},\"facet_dates\":{},\"facet_ranges\":{},\"facet_intervals\":{}},\"spellcheck\":{\"suggestions\":[\"correctlySpelled\",true]}}\n", :symbolize_names => true) }
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
