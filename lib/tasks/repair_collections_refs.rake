namespace :hydranorth do
  desc 'Repair objects whose hasCollection property has been replaced with hasCollection_ref'
  
  task :repair_collections_refs => :environment do
    GenericFile.all.each do |file|
      response, xml = Hydranorth::RawFedora.get(file.id, 'fcr:export', format: 'jcr/xml')
      next unless response == 200
      
      unless xml.xpath('//sv:property[@sv:name="ns002:hasCollection_ref"]').empty?
        c = Collection.find(file.hasCollectionId.first)
        
        # removing and re-adding the file should replace the file's collection_ref
        # with the actual collection information
        c.remove_member_id(file.id)
        c.add_member_ids [file.id]
      end
    end
  end
end