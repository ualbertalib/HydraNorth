require 'spec_helper'

describe CollectionsController do
  routes { Hydra::Collections::Engine.routes }
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  let(:user) { FactoryGirl.create(:user) }

  describe "#update" do
    before { sign_in user }

    let(:collection) do
      Collection.create(title: "Collection Title") do |collection|
        collection.apply_depositor_metadata(user.user_key)
      end
    end

    context "a collections members" do
      before do
        @asset1 = GenericFile.new(title: ["First of the Assets"])
        @asset1.apply_depositor_metadata(user.user_key)
        @asset1.save
        @asset2 = GenericFile.new(title: ["Second of the Assets"], depositor: user.user_key)
        @asset2.apply_depositor_metadata(user.user_key)
        @asset2.save
        @asset3 = GenericFile.new(title: ["Third of the Assets"], depositor:'abc')
        @asset3.apply_depositor_metadata(user.user_key)
        @asset3.save
      end

      it "should set collection on members" do
        put :update, id: collection, collection: {members:"add"}, batch_document_ids: [@asset3.id, @asset1.id, @asset2.id]
        expect(response).to redirect_to routes.url_helpers.collection_path(collection)
        expect(assigns[:collection].members).to match_array [@asset2, @asset3, @asset1]
        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["id:\"#{@asset2.id}\""],fl:['id',Solrizer.solr_name(:collection)]}
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["id"]).to eq @asset2.id
        afterupdate = GenericFile.find(@asset2.id)
        expect(doc[Solrizer.solr_name(:collection)]).to eq afterupdate.to_solr[Solrizer.solr_name(:collection)]

        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["id:\"#{@asset2.id}\""],fl:['hasCollection_ssim']}
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["hasCollection_ssim"]).to eq ["Collection Title"]

        put :update, id: collection, collection: {members:"remove"}, batch_document_ids: [@asset2]
        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["id:\"#{@asset2.id}\""],fl:['id',Solrizer.solr_name(:collection)]}
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["id"]).to eq @asset2.id
        afterupdate = GenericFile.find(@asset2.id)
        expect(doc[Solrizer.solr_name(:collection)]).to be_nil

        asset_results = ActiveFedora::SolrService.instance.conn.get "select", params:{fq:["id:\"#{@asset2.id}\""],fl:['hasCollection_ssim']}
        expect(asset_results["response"]["numFound"]).to eq 1
        doc = asset_results["response"]["docs"].first
        expect(doc["hasCollection_ssim"]).to_not eq ["Collection Title"]
      end
    end
  end
end
