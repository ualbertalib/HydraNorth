require './lib/tasks/rake_logger'
require 'active_fedora/noid'
require 'yaml'
require 'rdf/turtle'

namespace :hydranorth do
  namespace :solr do

    desc "Index objects by batch files"
    task :batch_index, [:batch_dir] => :environment do |t, args|
      batch_dir = args[:batch_dir]
      raise "Please provide a directory where the batch files are located" if batch_dir.nil?
      RakeLogger.info "Run through all the files in #{batch_dir}"
      Dir.glob(batch_dir+"*").each do |f|
        RakeLogger.info "Currently working on file #{f}"
        start = Time.now
        File.open(f, 'r+').each_line do |l|
          noid = l.strip
          RakeLogger.info "Currently working on #{noid}"
          begin
            ActiveFedora::Base.find(noid).update_index
          rescue Exception => e
            RakeLogger.error "ERROR: #{noid} with #{e.message}"
          end
        end
        finish = Time.now
        used_time = finish - start
        RakeLogger.info "This file #{f} used #{used_time}"
      end
    end

    desc "Index a single object in solr"
    task :index, [:id] => :environment do |t, args|
      id = args[:id]
      raise "Please provide a id" if id.nil?
      start = Time.now
      ActiveFedora::Base.find(id).update_index
      finish = Time.now
      used_time = finish - start
      RakeLogger.info "reindexed #{id} used #{used_time}"
    end

    desc "Index with a pairtree"
    task "index_pairtree", [:input] => :environment do |t, args|
      input = args[:input]
      RakeLogger.info "***********START index_pairtree***************"
      read_config
      RakeLogger.info "reindex #{input}"
      index_pairtree(input)
      RakeLogger.info "***********FINISH index_pairtree**************"
    end

    desc "Complete Reindex"
    task "reindex_all" => :environment do |t, args|
      RakeLogger.info "***********START reindex *********************"
      read_config
      start = Time.now
      count = index_all_objects
      finish = Time.now
      used_time = finish-start
      RakeLogger.info "A Complete Reindex of #{count} objects, used #{used_time}"
      RakeLogger.info "***********FINISH index_pairtree**************"
    end

    def read_config
      rails_env = Rails.env

      config = YAML.load_file("config/fedora.yml")
      @user = config[rails_env]['user']
      @password = config[rails_env]['password']
      @rest = config[rails_env]['url']
      @base_path = config[rails_env]['base_path']
    end

    def index_all_objects
       count = 0
       [(0..9),('a'..'z')].map {|i| i.to_a}.flatten.each do |a|
          [(0..9),('a'..'z')].map {|i| i.to_a}.flatten.each do |b|
            pairtree = a.to_s + b.to_s
            number_reindexed = index_pairtree(pairtree)
            count = count + number_reindexed
         end
       end
       return count
    end

    def index_pairtree(pairtree)
      RakeLogger.info "Start to reindex all objects starting with #{pairtree}"
      start = Time.now
      objects = find_objects(pairtree)
      RakeLogger.info "Reindex #{objects.size} objects"
      objects.each do |o|
        index_single(o)
      end
      finish = Time.now
      used_time = finish-start
      RakeLogger.info "Indexed #{objects.size} objects that starts with #{pairtree}, used #{used_time} seconds"
      return objects.size
    end

    def find_objects(input)
      require 'rest-client'
      objects=[]
      if input.length == 2
        RakeLogger.info "It's a pairtree root: #{input}"
        pairtree = @rest+@base_path+"/"+input
        RakeLogger.info "Pairtree: #{pairtree}"
        begin
          resource = RestClient::Resource.new(pairtree, :user => @user, :password => @password)
          data = resource.get(:accept => "text/turtle")
          graph = RDF::Graph.new << RDF::Turtle::Reader.new(data)
          ldp = RDF::Vocabulary.new("http://www.w3.org/ns/ldp#")
          ldpcontains = ldp["contains"]

          graph.each_statement do |statement|
            pred = statement.predicate
            if pred.term? and pred == ldpcontains
              id = statement.object.relativize(statement.object.parent).to_s
              if id.include? "-"
                RakeLogger.info "Not a noid: #{id}"
              else
                RakeLogger.info "An ERA Object: #{statement.object.to_s}"
                objects << id
              end
            end
          end
        rescue => e
          RakeLogger.error "#{e}"
        end
      else
        objects << input
      end
      return objects
    end

    def index_single(id)
      RakeLogger.info "start reindexing #{id}"
      start = Time.now
        ActiveFedora::Base.find(id).update_index
      finish = Time.now
      used_time = finish - start
      RakeLogger.info "reindexed #{id} used #{used_time}"
    end
  end
end


