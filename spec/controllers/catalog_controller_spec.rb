require 'spec_helper'

describe CatalogController, :type => :controller do
  routes { Rails.application.class.routes }

  let(:user) { FactoryGirl.find_or_create(:jill) }


  before do
    sign_in user
  end

  describe "#index" do
    before do
      @gf1 = GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], resource_type: ['book'], read_groups: ['public']).tap do |f|
        f.apply_depositor_metadata('mjg36')
        f.save!
      end

      @gf2 = GenericFile.new(title: ['Test 2 Document'], filename: ['test2.doc'], read_groups: ['public']).tap do |f|
        f.apply_depositor_metadata('mjg36')
        f.save!
      end

      @collection = Collection.new(title: 'Test').tap do |f|
        f.apply_depositor_metadata('mjg36')
        f.member_ids = [@gf1.id]
        f.save!
      end

      @editable_file = GenericFile.new.tap do |f|
        f.apply_depositor_metadata(user.user_key)
        f.save!
      end
    end

    after do
#      GenericFile.destroy_all
#      Collection.destroy_all
    end

    describe "term search" do
      it "should find records" do
        get :index, q: "book", owner: 'all'
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).map(&:id)).to eq [@gf1.id]
        expect(assigns(:document_list).count).to eq 1
        expect(assigns(:document_list).first[Solrizer.solr_name("title")]).to eq ['Test Document PDF']
      end
    end

    describe "facet search" do
      it "should have docs and facets for existing facet value", :integration => true do
        get :index, f: {"hasCollection" => 'Test'}
        expect(response).to be_successful
        expect(assigns(:document_list).count).to eq 1
      end
    end

  end
end

def assert_facets_have_values(aggregations)
  expect(aggregations).to_not be_empty
  # should have at least one value for each facet
  aggregations.each do |key, facet|
    expect(facet.items).to have_at_least(1).item
  end
end
