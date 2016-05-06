require 'rest-client'
# we use active_fedora/noid to generate pairtrees from noids
require 'active_fedora/noid'
require 'yaml'
require 'rdf/turtle'
require File.expand_path('../../../config/environment', __FILE__)

def read_config
  rails_env = Rails.env
  config = YAML.load_file("config/fedora.yml")
  @user = config[rails_env]['user']
  @password = config[rails_env]['password']
  @rest = config[rails_env]['url']
  @base_path = config[rails_env]['base_path']
end

def patch(path, payload)
  puts 'Patching ' + path + ': ' + payload
  response = RestClient::Request.execute(
    method: :patch,
    url: path,
    user: @user,
    password: @password,
    payload: payload,
    headers: {:content_type => "application/sparql-update", cache_control: :no_cache})
  return response.code
end

def handle_triples(triple_file)
  File.foreach(triple_file, "###") do |block|
    noid = block[/NOID:\s*([0-9A-Za-z]+)/,1]
    payload = block[/\|(.*)/,1]
    path = noid_path(noid) if noid
    begin 
      response = patch(path, payload).to_s unless payload.length > 4000
    rescue => e
      puts e
      @f.puts e
    end
    
    puts "Patched #{noid}: #{response}"
    @f.puts "Patched #{noid} with #{payload}: #{response}"
    @fixed += 1
  end
end

def noid_path(noid)
  read_config
  # note: treeify adds a trailing CR
  pairtree = ActiveFedora::Noid.treeify(noid).strip
  # the pairtree path of the item in question
  path = @rest+@base_path+"/"+ pairtree
end

def retrieve_triples(noid)
   read_config
   path = noid_path(noid)
   resource = RestClient::Resource.new(path, :user => @user, :password => @password)
   data = resource.get(:accept => "text/turtle")
   graph = RDF::Graph.new << RDF::Turtle::Reader.new( data )
end

def find_matching_triples(noid, pred)
   graph = retrieve_triples(noid)
   graph.each_statement do |statement|
     return statement if statement.predicate == pred
   end
   return nil 
end

def find_objects(input)
  objects=[]
  if input.length == 2
    puts "It's a pairtree root"
    pairtree = @rest+@base_path+"/"+input
    puts "Pairtree: " + pairtree
    begin 
      resource = RestClient::Resource.new(pairtree, :user => @user, :password => @password)
      data = resource.get(:accept => "text/turtle")
      graph = RDF::Graph.new << RDF::Turtle::Reader.new(data)
      ldp = RDF::Vocabulary.new("http://www.w3.org/ns/ldp#")
      ldpcontains = ldp["contains"]

      @fixable = 0
      @notfixable = 0
      graph.each_statement do |statement|
        pred = statement.predicate
        if pred.term? and pred == ldpcontains
          id = statement.object.relativize(statement.object.parent).to_s
 	  if id.include? "-"
            puts "Not a noid: " + id
	    notfixable += 1
          else
	    puts "An ERA Object: " + statement.object.to_s
            fixable += 1
            objects << id
          end
        end
      end
    rescue => e
      puts e
    end
  else
    objects << input
  end
  puts objects
  return objects 
end

def fix_theses_related_dates(input)
  objects = find_objects(input)
  objects.each do |o|
    #remove thesis-only date fields from non-thesis items (date_submitted, date_accepted)
    date_submitted_triple = find_matching_triples(o, "http://purl.org/dc/terms/dateSubmitted")
    date_accepted_triple = find_matching_triples(o, "http://purl.org/dc/terms/dateAccepted")
    puts date_submitted_triple
    puts date_accepted_triple
    path = noid_path(o)
    if date_submitted_triple
      date_submitted_sparql = construct_sparql(date_submitted_triple) if date_submitted_triple
      puts date_submitted_sparql
      begin
	response = patch(path, date_submitted_sparql).to_s
      rescue => e
	puts e
      end
      puts "Patched #{o} with #{date_submitted_triple}: #{response}"
      @f.puts "Patched #{o} with #{date_submitted_triple}: #{response}"
      @fixed += 1
    end
    if date_accepted_triple
      date_accepted_sparql = construct_sparql(date_accepted_triple) if date_accepted_triple
      begin
        response = patch(path, date_accepted_sparql).to_s
      rescue => e
        puts e
      end
      puts "Patched #{o} with #{date_accepted_triple}: #{response}"
      @f.puts "Patched #{o} with #{date_accepted_triple}: #{response}"
      @fixed += 1
    end
  end
end

def reindex_single(id)
  start = Time.now
  ActiveFedora::Base.find(args[:id]).update_index
  finish = Time.now
  used_time = finish - start
  puts "reindexed #{id} used #{used_time}"
end

def reindex(input)
  objects = find_objects(input)
  objects.each do |o|
    reindex_single(o)
  end
end



def construct_sparql(statement)
  return "DELETE { <> <#{statement.predicate}> \"#{statement.object}\" } WHERE { }"
end

@fixed = 0
@f = File.open('audit-fix.log', 'a+')

beginning_time = Time.now
input = ARGV[1]
fix_type = ARGV[0]
read_config
if fix_type == 'triples' and input and File.file?(input)
  begin
    handle_triples(input)
  rescue => e
    puts e
  end
elsif fix_type == 'thesis'
  fix_theses_related_dates(input)
elsif fix_type == 'reindex'
  reindex(input) 
end

end_time = Time.now

puts "Fixed objects: " + @fixed.to_s, (end_time - beginning_time)*1000
@f.puts "Fixed objects: " + @fixed.to_s, (end_time - beginning_time)*1000
