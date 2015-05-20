require 'spec_helper'

describe 'cloud', :type => :routing do
  routes { BrowseEverything::Engine.routes }

  it { expect(get("/browse/connect")).to be_routable }
  it { expect(get("/browse/connect")).to route_to(controller: "browse_everything", action: "show", provider: "browse", path: "connect") }

end
