namespace :hydranorth do
  desc 'Reindex collections'

  task :reindex_collections => :environment do
    Collection.all.each do |collection|
      collection.save
    end
  end
end
