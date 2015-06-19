module Hydranorth
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern
    include Sufia::CollectionsControllerBehavior

    def show
      if current_user && current_user.admin?
        self.search_params_logic -= [:add_access_controls_to_solr_params]
      end
    
      super
      presenter
    end

    protected

    def presenter_class
      Hydranorth::CollectionPresenter
    end

    def collection_params
      params.require(:collection).permit(:title, :description, :license, :members, part_of: [],
        creator: [], date_created: [], subject: [],
        rights: [], resource_type: [], identifier: [])
       
    end

    def form_class
      Hydranorth::Forms::CollectionEditForm
    end

    protected

    def add_members_to_collection collection = nil
      collection ||= @collection
      collection.member_ids = batch.concat(collection.member_ids)
      batch.each do |id|
        begin
          member = ::GenericFile.find(id) || Collection.find(id)
        rescue
        end
        if member.respond_to? :hasCollection
          hasCollection = member.hasCollection
          hasCollection.push collection.title
          member.hasCollection = hasCollection
          member.save!
        end
      end
    end

    def remove_members_from_collection
      @collection.members.delete(batch.map { |pid| ActiveFedora::Base.find(pid) })
      batch.each do |id|
        begin
          member = ::GenericFile.find(id) || Collection.find(id)
        rescue
        end
        if member.respond_to? :hasCollection
          hasCollection = member.hasCollection
          hasCollection.delete collection.title
          member.hasCollection = hasCollection
          member.save!
        end
      end
    end

  end
end
