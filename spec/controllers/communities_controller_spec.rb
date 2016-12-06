require 'spec_helper'

describe CommunitiesController, :type => :controller do
  it "responds with success" do
    get :index
    expect(response).to be_successful
  end
end
