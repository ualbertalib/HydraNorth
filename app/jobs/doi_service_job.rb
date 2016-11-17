class DOIServiceJob < ActiveJob::Base
  queue_as :default

  def perform(generic_file_id, type = 'create')
    file = GenericFile.find(generic_file_id)
    Hydranorth::DOIService.new(file).send(type) if file
  end
end
