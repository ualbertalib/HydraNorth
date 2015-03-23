class BatchEditsController < ApplicationController
   include Hydra::BatchEditBehavior
   include GenericFileHelper
   include Hydranorth::BatchEditsControllerBehavior
end
