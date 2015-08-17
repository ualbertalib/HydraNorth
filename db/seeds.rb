# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# HYDRANORTH - PLEASE NOTE:
# When adding new initial data 
# please make sure you use methods or conditions to avoid duplication of the data/record
# as rake db:seed may be run after the initial setup


if !User.find_by_user_key("dittest@ualberta.ca")

  admin = User.new({
      :email => "dittest@ualberta.ca",
      :password => "password",
      :password_confirmation => "password",
      :group_list => "admin" # this is the important part
    }) unless User.find_by_user_key("dittest@ualberta.ca")

  admin.skip_confirmation!
  admin.save!
end

# create a dummy admin user for dataverse
if !User.find_by_user_key("dit.application.test@ualberta.ca")

  admin = User.new({
      :email => "dit.application.test@ualberta.ca",
      :password => "password",
      :password_confirmation => "password",
      :group_list => "admin" # this is the important part
    }) unless User.find_by_user_key("dit.application.test@ualberta.ca")

  admin.skip_confirmation!
  admin.save!
end

# IDs of the collections created below will be added to config/initializers/sufia.rb
# please restart httpd after rake db:seed
not_exists = Collection.find_with_conditions('depositor' => 'dittest@ualberta.ca', 'title' => 'Communities').empty?
if not_exists 
  official = Collection.new(title: "Communities")
  official.apply_depositor_metadata("dittest@ualberta.ca")
  official.save!
end

dataverse_not_exists = Collection.find_with_conditions('depositor' => 'dit.application.test@ualberta.ca', 'title' => 'Dataverse Datasets').empty?
if dataverse_not_exists
  official = Collection.new(title: "Dataverse Datasets")
  official.apply_depositor_metadata("dit.application.test@ualberta.ca")
  official.save!
end

  
theses = Collection.find_or_create_with_type("Thesis").tap do |c|
  c.apply_depositor_metadata("dittest@ualberta.ca")
  c[:fedora3uuid] = "uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269"
end
theses.save!

cstr = Collection.find_or_create_with_type("Computing Science Technical Report").tap do |c|
  c.apply_depositor_metadata("dittest@ualberta.ca")
  c[:fedora3uuid] = "uuid:33713a7b-b387-4a7e-8d9e-860df87c1fe5"
end
cstr.save!

ser = Collection.find_or_create_with_type("Structural Engineering Report").tap do |c|
  c.apply_depositor_metadata("dittest@ualberta.ca")
  c[:fedora3uuid] = "uuid:b1535044-2f60-4e24-89de-c3a400d4255b"
end
ser.save!

config = File.read("config/initializers/sufia.rb", &:read)
config = config.gsub(/^.*config\.cstr_collection_id.*$/, '')
config = config.gsub(/^.*config\.ser_collection_id.*$/, '')
config = config.gsub(/(^.*config\.special_types.*$)/, '  config.cstr_collection_id = "'+cstr.id+'"'+"\n"+'\1')
config = config.gsub(/(^.*config\.special_types.*$)/, '  config.ser_collection_id = "'+ser.id+'"'+"\n"+'\1')

File.write("config/initializers/sufia.rb", config)
