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
    url: @rest+path,
    user: @user,
    password: @password,
    payload: payload,
    headers: {:content_type => "application/sparql-update", cache_control: :no_cache})
  return response.code
end

def handle_triples(triple_file)
  File.foreach(triple_file, "###") do |block|
    noid = block[/NOID:([0-9A-Za-z]*)/,1]
    payload = block[/\|(.*)/,1]
    path = noid_path(noid) if noid
    puts block
    puts noid
    puts "Patched #{noid}: " + patch(path, payload).to_s
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

@fixed = 0
require File.expand_path('../../../config/environment', __FILE__)
input_file = ARGV[0]
raise "missing argument: file contains triples" unless input_file or !input_file.file?
beginning_time = Time.now

if File.file?(input_file)
  begin
    read_config
    handle_triples(input_file)
  rescue => e
    puts e
  end
end
end_time = Time.now

puts "Fixed objects: " + @fixed.to_s, (end_time - beginning_time)*1000

