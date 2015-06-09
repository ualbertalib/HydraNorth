# borrowed and developed based on psu-stewardship/scholarsphere/lib/tasks/scholarsphere.rake

namespace :hydranorth do

  def logger
    Rails.logger
  end

  desc "Update Resource Type for selected collections"
  task :update_special_itemtype => :environment do |t, args|
    uuids = {'uuid:33713a7b-b387-4a7e-8d9e-860df87c1fe5' => 'Computing Science Technical Report', 'uuid:b1535044-2f60-4e24-89de-c3a400d4255b' => 'Structural Engineering Report'}
    uuids.each do |uuid, resource_type|
      solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", 
              params: {:q => 'fedora3uuid_tesim:'+uuid.to_s}
      numFound = solr_rsp['response']['numFound']
      if numFound == 1
        id = solr_rsp['response']['docs'].first['id']
      else
        logger.error "Number of Collection retrieved by #{uuid} is incorrect: #{numFound}"
      end
      Collection.find(id).member_ids.each do |fid|
        file = GenericFile.find(fid)
        file.resource_type = [resource_type]      
        file.save
      end
    end
     
  end

  desc "Characterize all files"
  task characterize: :environment do
    # grab the first increment of document ids from solr

    resp = ActiveFedora::SolrService.instance.conn.get "select",
              params:{ fl:['id'], fq: "#{ Solrizer.solr_name("has_model", :symbol)}:GenericFile"}
    #get the totalNumber and the size of the current response
    totalNum =  resp["response"]["numFound"]
  
    resp = ActiveFedora::SolrService.instance.conn.get "select",
              params:{ fl:['id'], fq: "#{ Solrizer.solr_name("has_model", :symbol)}:GenericFile", rows: totalNum }
    idList = resp["response"]["docs"]

    # for each document in the database call characterize
    idList.each { |o|  Sufia.queue.push(CharacterizeJob.new(o["id"]))}
  end

  desc "Re-solrize all objects"
  task resolrize: :environment do
    Sufia.queue.push(ResolrizeJob.new)
  end

  namespace :export do
    desc "Dump metadata as RDF/XML for e.g. Summon integration"
    task rdfxml: :environment do
      raise "rake scholarsphere:export:rdfxml output=FILE" unless ENV['output']
      export_file = ENV['output']
      triples = RDF::Repository.new
      rows = GenericFile.count
      GenericFile.find(:all).each do |gf|
        next unless gf.rightsMetadata.groups["public"] == "read" && gf.descMetadata.content
        RDF::Reader.for(:ntriples).new(gf.descMetadata.content) do |reader|
          reader.each_statement do |statement|
            triples << statement
          end
        end
      end
      unless triples.empty?
        RDF::Writer.for(:rdfxml).open(export_file) do |writer|
          writer << triples
        end
      end
    end
  end

  namespace :harvest do

    desc "Harvest Geonames cities"
    task geonames_cities: :environment do |cmd, args|
      system "curl 'http://download.geonames.org/export/dump/cities1000.zip' -o '/tmp/cities1000.zip'"
      system "unzip -o '/tmp/cities1000.zip' -d '/tmp'" 
      vocabs = ["/tmp/cities1000.txt"]
      LocalAuthority.harvest_tsv(cmd.to_s.split(":").last, vocabs, prefix: 'http://sws.geonames.org/')
    end
  end

  namespace "checksum" do
    desc "Run a checksum on all the GenericFiles"
    task "all"  => :environment do
      errors =[]
      GenericFile.all.each do |gf|
        next unless gf.content.checksum.blank?
        gf.content.checksumType="MD5"
        if gf.content.checksum == gf.original_checksum[0]
          gf.content.checksumType="SHA-1"
          gf.save # to do update version committer to checksum
        else
          errors << gf
        end
      end
      errors.each {|gf| puts "Invalid Checksum: #{gf.pid} new: #{gf.content.checksum} original: #{gf.original_checksum[0]} "}

    end
  end

  desc "Generate thumbnails for ALL documents"
  task "generate_thumbnails" => :environment do

    solr = ActiveFedora::SolrService.instance.conn.get "select",
                  params:{ fl:['id'], fq: "#{ Solrizer.solr_name("has_model", :symbol)}:GenericFile"}
    total_docs = solr["response"]["numFound"]
    
    solr = ActiveFedora::SolrService.instance.conn.get "select",
                                  params:{ fl:['id'], fq: "#{ Solrizer.solr_name("has_model", :symbol)}:GenericFile",
                                  rows: total_docs}
    docs = solr["response"]["docs"]
    docs.each do |doc|
      begin
        id = doc["id"]
        Sufia.queue.push(CreateDerivativesJob.new id)
      rescue Exception => e  
        errors += 1
        logger.error "Error processing document: #{id}\r\n#{e.message}\r\n#{e.backtrace.inspect}"  
      end
    end

  end

  # Start date must be in format 'yyyy/MM/dd'
  desc "Prints to stdout a list of failed jobs in resque"
  task "get_failed_jobs", [:start_date, :details] => :environment do |cmd, args|
    details = (args[:details] == "true") 
    start_date = args[:start_date] || Date.today.to_s.gsub('-', '/')
    log = ""
    i = 0
    puts "Getting failed jobs from: #{start_date}"
    Resque::Failure.each do |i, job| 
      i += 1 
      job_failed_at = job["failed_at"]
      if job_failed_at >= start_date
        payload = job["payload"]
        job_args64 = payload["args"]
        job_args = Base64.decode64(job_args64[0])
        prefix_at = job_args.index("scholarsphere:") 
        if prefix_at == nil
          log += "Unexpected job arguments found: #{job_args}\r\n"
        else
          sufix_at = job_args.index(":", prefix_at + 14)
          pid = job_args[prefix_at, sufix_at-prefix_at-1].chomp
          if details

            exception = job["exception"]
            error = job["error"]
            backtrace = job["backtrace"][0]
            log += "PID: #{pid}\r\n"
            log += "Failed at: #{job_failed_at}\r\n"
            log += "Exception: #{exception} - #{error}\r\n"
            log += "Backtrace: #{backtrace}\r\n" 
            begin
              gf = GenericFile.find(pid)
              log += "File name: #{gf[:filename]}\r\n"
              log += "Mime type: #{gf[:mime_type]}\r\n"
            rescue Exception => e  
              log += "File name: (could not be determined)\r\n"
            end
            log += "---------------\r\n"
          else
            log += "#{pid}\r\n"
          end
        end
        puts i if (i % 100) == 0
      end
    end

    puts "Writting log..."
    File.write('find_failed_jobs.log', log)
    puts "Done."

  end

  desc "Create derivatives for the documents indicated in a file. Each line in the file must include a PID (e.g. scholarsphere:123xyz)"
  task "generate_thumbnail", [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    abort "Must provide a file name to read the PIDs" if file_name == nil
    puts "Processing file #{file_name}"
    File.readlines(file_name).each do |line|
      pid = line.chomp
      unless pid.empty?
        Sufia.queue.push(CreateDerivativesJob.new pid)
        puts "Queued derivatives for PID: #{pid}"
      end
    end
  end  

  desc "Characterizes documents indicated in a file. Each line in the file must include a PID (e.g. scholarsphere:123xyz)"
  task "characterize_some", [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    abort "Must provide a file name to read the PIDs" if file_name == nil
    puts "Processing file #{file_name}"
    File.readlines(file_name).each do |line|
      pid = line.chomp
      unless pid.empty?
        Sufia.queue.push(CharacterizeJob.new pid)
        puts "Queued characterization for PID: #{pid}"
      end
    end
  end    

end
