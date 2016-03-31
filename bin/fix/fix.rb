require 'rest-client'
# we use active_fedora/noid to generate pairtrees from noids
require 'active_fedora/noid'

require 'rdf/turtle'

instance = 'dev'

$user = 'user'
$password = 'password'
$rest = 'http://@server:8983/fedora/rest'
$originalroot = $rest

$fixed = 0
$notfixed = 0

$ualterms = RDF::Vocabulary.new("http://terms.library.ualberta.ca/identifiers/")
$ualrole = RDF::Vocabulary.new("http://terms.library.ualberta.ca/role/")
$ualid = RDF::Vocabulary.new("http://terms.library.ualberta.ca/id/")
$ualdate = RDF::Vocabulary.new("http://terms.library.ualberta.ca/date/")
$ualthesis = RDF::Vocabulary.new("http://terms.library.ualberta.ca/thesis/")

def handleNoid(noid, instance)

	def patch(path, payload)
		puts 'Patching ' + path + ': ' + payload
		response = RestClient::Request.execute(
			method: :patch, 
			url: $rest + path, 
			user: $user,
			password: $password,
			payload: payload,
			headers: {:content_type => "application/sparql-update", cache_control: :no_cache})
		return response.code
	end

	# note: treeify adds a trailing CR
	pairtree = ActiveFedora::Noid.treeify(noid).strip

	# the pairtree path of the item in question
	$path = "/" + instance + "/" + pairtree

	payload = ""

	private_resource = RestClient::Resource.new $originalroot + $path, $user, $password
	data = private_resource.get :accept => :ttl
	graph = RDF::Graph.new << RDF::Turtle::Reader.new( data )

	graph.each_statement do |statement|
		pred = statement.predicate
		if pred.term?
			if pred.parent.to_s == "http://terms.library.library.ca/identifiers/"
				# use uri methods to grab the term off the end of the bad uri,
				# and use it to build a good uri
				term = pred.relativize(pred.parent).to_s
				case term
				when "ingestbatch", "year_created", "belongsToCommunity", "is_community", "is_admin_set", "is_official", "hasCollection", "hasCollectionId", "remote_resource"
	  				statement.predicate = $ualterms[term]
				when "thesiscommitteemember"
					statement.predicate = $ualrole[term]
				when "fedora3uuid", "fedora3handle", "proquest", "ser", "trid", "unicorn"
					statement.predicate = $ualid[term]
				when "graduationdate"
					statement.predicate = $ualdate[term]
				when "thesislevel", "specialization"
					statement.predicate = $ualthesis[term]
				else
					# this will leave the original predicate in place, so no new triple will be added
					puts "ERROR in noid " + noid + ": unknown term " + term
				end
				# only add the new triple if it doesn't already exist
				# (i.e. this script is idempotent)
				payload += statement.to_s + "\n" unless graph.has_statement?(statement)
			end
			#TODO do the inverse operation: if a good triple does not match a bad triple, delete it
			# This will allow us to run an update operation after the fix, to pick up changes
			# that were made during the first run, while the bad URI was still in use
		end
	end

	#TODO look up the noid in a database of audit fixes and apply any fixes

	if payload != ""
	  payload = "INSERT DATA {" + payload + "}"
	  puts 'Patched ' + noid + ': ' + patch($path, payload).to_s
	  $fixed += 1
	else
	  puts "No changes for " + noid
	  $notfixed += 1
	end

end

# pass in a two-character pairtree root or a single noid
input = ARGV[0]
raise "missing argument: noid or pairtree root" unless input

beginning_time = Time.now

if input.length == 2
	puts "It's a pairtree root"
	# fetch contents of pairtree root
	pairtree = $originalroot + "/" + instance + "/" + input
	puts "Pairtree: " + pairtree
	begin
		private_resource = RestClient::Resource.new pairtree, $user, $password
		data = private_resource.get :accept => :ttl
		graph = RDF::Graph.new << RDF::Turtle::Reader.new( data )

		ldp = RDF::Vocabulary.new("http://www.w3.org/ns/ldp#")
		ldpcontains = ldp["contains"]

		fixable = 0
		notfixable = 0

		graph.each_statement do |statement|
			pred = statement.predicate
			if pred.term?
				if pred == ldpcontains
					id = statement.object.relativize(statement.object.parent).to_s
					if id.include? "-"
						puts "Not a noid: " + id
						notfixable += 1
					else
						puts "Needs fixing: " + statement.object.to_s
						fixable += 1
						handleNoid(id, instance)
					end
				end
			end
		end
	rescue => e
  		e.response
	end

	puts "Fixed objects: " + fixable.to_s
	end_time = Time.now
	# csv output of item counts and timing
	puts "LOG," + input + "," + fixable.to_s + "," + notfixable.to_s + "," + $fixed.to_s + "," + $notfixed.to_s + ",#{(end_time - beginning_time)*1000}"

else
	handleNoid(input, instance)
end
