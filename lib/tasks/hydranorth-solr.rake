require './lib/tasks/rake_logger'
require 'rest-client'
require 'active_fedora/noid'
require 'yaml'
require 'rdf/turtle'

namespace :hydranorth do
  namespace :solr do

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

    desc "update the index on all GenericFiles"
    task update_generic_file_index: :environment do
      GenericFile.all.each(&:update_index)
    end

    desc "Index with a pairtree"
    task "index_pairtree", [:input] => :environment do |t, args|
      input = args[:input]
      RakeLogger.info "***********START index_pairtree***************"
      read_config
      start = Time.now
      objects = find_objects(input)
      objects.each do |o|
        index_single(o)
      end
      finish = Time.now
      used_time = finish - start
      RakeLogger.info "Indexed #{objects.size} objects, used #{used_time}"
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

    def find_objects(input)
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
      start = Time.now
        ActiveFedora::Base.find(id).update_index
      finish = Time.now
      used_time = finish - start
      RakeLogger.info "reindexed #{id} used #{used_time}"
    end
  end
end
