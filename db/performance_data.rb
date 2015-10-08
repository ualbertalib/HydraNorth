northern = Collection.find(title: "Northern North America Collection").first
northern ||= Collection.new.tap do |c|
  c.apply_depositor_metadata "eraadmi@ualberta.ca" 
  c.creator = ["eraadmi@ualberta.ca"]
  c.title = "Northern North America Collection"
  c.description = "These images were donated to the University of Alberta by Dr. Joel Martin Halpern, a prominent anthropologist who did extensive work in the northern parts of North America." 
  c.fedora3uuid = "uuid:f1fc4163-ee06-4347-a387-2f430b140643"
  c.is_official = true
  c.save!
end

files = []

if 0 == northern.members.count
  1132.times do |i|
    print '*' 
    file = GenericFile.create do |gf| 
      gf.apply_depositor_metadata('eraadmi@ualberta.ca')
      gf.read_groups = ['public']
    end
    files << file
  end
  northern.members << files
  northern.save!
end
