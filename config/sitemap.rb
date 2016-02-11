Sitemap::Generator.instance.load(host: 'era.library.ualberta.ca') do
  path :root, priority: 1, change_frequency: 'weekly'
  path :catalog_index, priority: 1, change_frequency: 'weekly'
  User.all.each do |user|
    literal Sufia::Engine.routes.url_helpers.profile_path(user.to_param), priority: 0.8, change_frequency: 'daily'
  end
  read_group = Solrizer.solr_name('read_access_group', :symbol)
  solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('read_access_group', :symbol)+':public', :fl => "id,#{Solrizer.solr_name('active_fedora_model', :stored_sortable)}"} 
  numFound = solr_rsp['response']['numFound']
  if 10 < numFound
    solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('read_access_group', :symbol)+':public', :fl => "id,#{Solrizer.solr_name('active_fedora_model', :stored_sortable)}", :rows => numFound } 
  end
  solr_rsp['response']['docs'].each do |o|
    case o[Solrizer.solr_name('active_fedora_model', :stored_sortable)]
    when 'GenericFile'
      literal Sufia::Engine.routes.url_helpers.generic_file_path(o['id']), priority: 1, change_frequency: 'weekly'
    when 'Collection'
      literal Hydra::Collections::Engine.routes.url_helpers.collection_path(o['id']), priority: 1, change_frequency: 'weekly'
    end
  end
end
