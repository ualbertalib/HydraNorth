Sitemap::Generator.instance.load(host: 'era.library.ualberta.ca') do
  path :root, priority: 1, change_frequency: 'weekly'
  read_group = Solrizer.solr_name('read_access_group', :symbol)
  solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('read_access_group', :symbol)+':public', :fl => "id,#{Solrizer.solr_name('active_fedora_model', :stored_sortable)}"} 
  numFound = solr_rsp['response']['numFound']
  if 10 < numFound
    solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('read_access_group', :symbol)+':public', :fl => "id,#{Solrizer.solr_name('system_modified', :stored_sortable, type: :date)},#{Solrizer.solr_name('active_fedora_model', :stored_sortable)}", :rows => numFound } 
  end
  solr_rsp['response']['docs'].each do |o|
    case o[Solrizer.solr_name('active_fedora_model', :stored_sortable)]
    when 'GenericFile'
      gf = GenericFile.find(o['id'])
      literal Sufia::Engine.routes.url_helpers.generic_file_path(o['id']), priority: 1, change_frequency: 'weekly', updated_at: o[Solrizer.solr_name('system_modified', :stored_sortable, type: :date)], metadata: { hash: gf.characterization.digest.first.to_s, length: gf.file_size.first, type: gf.mime_type }
    when 'Collection'
      literal Hydra::Collections::Engine.routes.url_helpers.collection_path(o['id']), priority: 1, change_frequency: 'weekly', updated_at: o[Solrizer.solr_name('system_modified', :stored_sortable, type: :date)]
    end
  end
end
