require 'spec_helper'
require 'performance_helper'
require 'benchmark'

describe CollectionsController, :type => :controller, slow: true do
  routes { Hydra::Collections::Engine.routes }


  context "index performance" do

    it 'should be fast' do
      expect( Benchmark.realtime{
        get :index
      }).to be < 0.5
    end

  end

end
