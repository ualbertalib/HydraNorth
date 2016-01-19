Ezid::Client.configure do |config|
  config.default_shoulder = "ark:/99999/fk4"
  config.user = "apitest"
  config.password = "apitest"
  config.identifier.defaults = {status: "public", profile: "datacite"}
end
