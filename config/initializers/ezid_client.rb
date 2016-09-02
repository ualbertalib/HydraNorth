Ezid::Client.configure do |config|
  config.default_shoulder = "ark:/99999/fk4"
  config.user = YOUR_USER
  config.password = YOUR_PASSWORD
  config.identifier.defaults = {status: "reserved", profile: "datacite"}
end
