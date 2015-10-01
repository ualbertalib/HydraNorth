require 'spec_helper'

describe 'redirect', :type => :routing do
  routes { Rails.application.class.routes }

  # item route
  it { expect(get("/public/view/item/uuid:394266f0-0e4a-42e6-a199-158165226426")).to route_to(
    controller: "redirect", action: "item", uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426") }

  # datastream route
  it { expect(get("/public/view/item/uuid:394266f0-0e4a-42e6-a199-158165226426/DS1")).to route_to(
    controller: "redirect", action: "datastream", uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426", ds: "DS1") }
  it { expect(get("/public/view/item/uuid:394266f0-0e4a-42e6-a199-158165226426/DS1/test.pdf")).to route_to(
    controller: "redirect", action: "datastream", uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426", ds: "DS1", file: "test", format: "pdf") }

  # collection route
  it { expect(get("/public/view/collection/uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7")).to route_to(
    controller: "redirect", action: "collection", uuid: "uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7") }

  # community route
  it { expect(get("/public/view/collection/uuid:d04b3b74-211d-4939-9660-c390958fa2ee")).to route_to(
    controller: "redirect", action: "collection", uuid: "uuid:d04b3b74-211d-4939-9660-c390958fa2ee") }

  # user profile route
  it { expect(get("/public/view/author/pcharoen")).to route_to(
    controller: "redirect", action: "author", username: "pcharoen") }

  # thesisdeposit route
  #it { expect(get("/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269")).to redirect_to(
  #  "https://thesisdeposit.library.ualberta.ca/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269") }

#  it "redircts to thesisdeposit" do
#    get '/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
#    expect(page.current_path).to eq 'https://thesisdeposit.library.ualberta.ca/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
#  end
end
