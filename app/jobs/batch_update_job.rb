class BatchUpdateJob
  include Hydra::PermissionsQuery
  include Sufia::Messages

  def queue_name
    :batch_update
  end

  attr_accessor :login, :title, :file_attributes, :batch_id, :visibility, :saved, :denied

  def initialize(login, batch_id, title, file_attributes, visibility)
    self.login = login
    self.title = title || {}
    Rails.logger.debug "TITLE #{title}"
    Rails.logger.debug "SELF.TITLE #{self.title}"
    self.file_attributes = file_attributes
    self.visibility = visibility
    self.batch_id = batch_id
    self.saved = []
    self.denied = []
  end

  def run
    batch = Batch.find_or_create(self.batch_id)
    user = User.find_by_user_key(self.login)
    Rails.logger.debug "RUN #{batch.inspect}"
    Rails.logger.debug "RUN2 #{batch.generic_files.inspect}"
    batch.generic_files.each do |gf|
      Rails.logger.debug "RUN3 #{gf.inspect}"
      update_file(gf, user)
    end

    batch.update(status: ["Complete"])

    if denied.empty?
      send_user_success_message(user, batch) unless saved.empty?
    else
      send_user_failure_message(user, batch)
    end
  end

  def update_file(gf, user)
    unless user.can? :edit, gf
      ActiveFedora::Base.logger.error "User #{user.user_key} DENIED access to #{gf.id}!"
      denied << gf
      return
    end
    gf.title = title[gf.id] if title[gf.id]
    gf.attributes = file_attributes
    gf.visibility= visibility
    save_tries = 0
    begin
      gf.save!
    rescue RSolr::Error::Http => error
      save_tries += 1
      ActiveFedora::Base.logger.warn "BatchUpdateJob caught RSOLR error on #{gf.id}: #{error.inspect}"
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
      sleep 0.01
      retry
    end #
    Sufia.queue.push(ContentUpdateEventJob.new(gf.id, login))
    saved << gf
    Rails.logger.debug "GF #{gf.inspect}"
  end

  def send_user_success_message user, batch
    message = saved.count > 1 ? multiple_success(batch.id, saved) : single_success(batch.id, saved.first)
    User.batchuser.send_message(user, message, success_subject, sanitize_text = false)
  end

  def send_user_failure_message user, batch
    message = denied.count > 1 ? multiple_failure(batch.id, denied) : single_failure(batch.id, denied.first)
    User.batchuser.send_message(user, message, failure_subject, sanitize_text = false)
  end
end
