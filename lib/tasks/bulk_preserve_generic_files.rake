namespace :hydranorth do
  desc 'Queues all Generic Files in the system for preservation'

  task :bulk_preserve_generic_files => :environment do
    GenericFile.all.each do |gf|
      Hydranorth::PreservationQueue.preserve(gf.id)
    end
  end
end
