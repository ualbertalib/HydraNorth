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
      begin
        gf = GenericFile.find(o['id'])
      rescue => e
        Rails.logger.error "id:#{o['id']} threw '#{e}' and it was not included in the sitemap.xml"
      else
        literal Sufia::Engine.routes.url_helpers.generic_file_path(o['id']), priority: 1, change_frequency: 'weekly', updated_at: o[Solrizer.solr_name('system_modified', :stored_sortable, type: :date)], metadata: { type: "text/html" }, link: { href: Sufia::Engine.routes.url_helpers.download_path(o['id']), rel: 'content', hash: gf.characterization.digest.first.to_s, length: gf.file_size.first, type: gf.mime_type }
      end
    when 'Collection'
      literal Hydra::Collections::Engine.routes.url_helpers.collection_path(o['id']), priority: 1, change_frequency: 'weekly', updated_at: o[Solrizer.solr_name('system_modified', :stored_sortable, type: :date)]
    end
  end
end
