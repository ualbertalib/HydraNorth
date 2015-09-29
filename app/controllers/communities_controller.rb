# communities are super-collections, which were needed to replicate the 
# model of ualbertalib's legacy repository. They can contain items but
# generally contain only collections.
class CommunitiesController < ApplicationController
  include Hydranorth::CommunitiesControllerBehavior
end
