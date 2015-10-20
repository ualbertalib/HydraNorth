class SingleUseLinksViewerController < ApplicationController
   include Sufia::SingleUseLinksViewerControllerBehavior

   self.presenter_class = Hydranorth::GenericFilePresenter
end
