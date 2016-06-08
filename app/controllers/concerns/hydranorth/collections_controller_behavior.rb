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

    def update 
     if params[:collection][:logo]
       mime_type = params[:collection][:logo].content_type
       original_filename = params[:collection][:logo].original_filename
       @collection.add_file(params[:collection][:logo].tempfile, path: 'logo', original_name: original_filename, mine_type: mime_type)
     end
     super
    end

    def create
     if params[:collection][:logo]
       mime_type = params[:collection][:logo].content_type
       original_filename = params[:collection][:logo].original_filename
       @collection.add_file(params[:collection][:logo].tempfile, path: 'logo', original_name: original_filename, mine_type: mime_type)
     end
     super
    end

    protected

    # override Sufia::CollectionsControllerBehavior#presenter to establish
    # a link between the presenter and the view context in which it will
    # present
    def presenter
      @presenter ||= presenter_class.new(@collection).tap do |p|
        p.render_context = view_context
      end
    end

    def presenter_class
      Hydranorth::CollectionPresenter
    end

    def collection_params
      params.require(:collection).permit(:title, :description, :license, :members, :is_official, :is_community, part_of: [],
        creator: [], date_created: [], subject: [],
        rights: [], resource_type: [], identifier: [])
    end

    def form_class
      Hydranorth::Forms::CollectionEditForm
    end

    protected

    def logo
      send_data(collection.logo, filename: "image", type: "text/xml", disposition: "inline")
    end
    
    # these methods enhacnce hydra-collection's collections_controller_behaviour

    def add_members_to_collection collection = nil
      collection ||= @collection
      collection.member_ids = batch.concat(collection.member_ids)
      collection.save
      batch.each do |id|
        begin
          member = ActiveFedora::Base.find(id)
        rescue
        end
        if collection.is_community?
          # "target is a community, add to belongsToCommunity"
          add_member_to_community(member, collection)
          if member.instance_of? Collection
            # "member is a collection, make all children inherit belongsToCommunity"
            member.materialized_members.each do |o|
              add_member_to_community(o, collection)
            end
          end
        end

        if member.respond_to? :hasCollection
          # "member is a file, add the target collection id to hasCollection"
          add_file_to_collection(member, collection)
        end

        if collection.belongsToCommunity?
          # "if the target collection has community, the children added should inherit its belongsToCommunity"
          belongsToCommunity = collection.belongsToCommunity + member.belongsToCommunity
          member.belongsToCommunity = belongsToCommunity
          member.save
        end
      end
    end

    def add_file_to_collection(file, collection)
      hasCollection = file.hasCollection
      hasCollection.push collection.title
      file.hasCollection = hasCollection
      hasCollectionId = file.hasCollectionId
      hasCollectionId.push collection.id
      file.hasCollectionId = hasCollectionId
      file.save!
    end

    def add_member_to_community(member, community)
      belongsToCommunity = member.belongsToCommunity
      belongsToCommunity.push community.id
      member.belongsToCommunity = belongsToCommunity
      member.save!
    end

    def remove_members_from_collection
      @collection.members.delete(batch.map { |pid| ActiveFedora::Base.find(pid) })
      batch.each do |id|
        begin
          member = ActiveFedora::Base.find(id)
        rescue
        end

        if collection.is_community?
          remove_member_from_community(member, collection)
          if member.instance_of? Collection
            member.members.each do |o|
              remove_member_from_community(o, collection)
            end
          end
        end
        if member.respond_to? :hasCollection
          remove_file_from_collection(member, collection)
        end
      end
    end

    def remove_member_from_community(member,collection)
      puts "remove belongsToCommunity from member"
      belongsToCommunity = member.belongsToCommunity
      belongsToCommunity.delete collection.id
      member.belongsToCommunity = belongsToCommunity
      member.save!
    end

    def remove_file_from_collection(file, collection)
      hasCollection = file.hasCollection
      hasCollection.delete collection.title
      file.hasCollection = hasCollection
      hasCollectionId = file.hasCollectionId
      belongsToCommunity = file.belongsToCommunity
      hasCollectionId.each do |cid|
        belongsToCommunity = belongsToCommunity - Collection.find(cid).belongsToCommunity
      end
      file.belongsToCommunity = belongsToCommunity
      hasCollectionId.delete collection.id
      file.hasCollectionId = hasCollectionId

      file.save!
    end

  end
end
