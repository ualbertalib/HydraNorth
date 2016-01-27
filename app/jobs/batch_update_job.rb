class BatchUpdateJob
  include Hydra::PermissionsQuery
  include Sufia::Messages

  def queue_name
    :batch_update
  end

  attr_accessor :login, :title, :trid, :ser, :file_attributes, :batch_id, :visibility, :saved, :denied, :embargo_release_date, :visibility_during_embargo,
                :visibility_after_embargo

  def initialize(login, batch_id, title, trid, ser, file_attributes, visibility, embargo_release_date=nil, visibility_during_embargo=nil,
                  visibility_after_embargo=nil)
    self.login = login
    self.title = title || {}
    if trid.present?
      self.trid = trid
    elsif ser.present?
      self.ser = ser
    end
    self.file_attributes = file_attributes
    self.visibility = visibility
    self.embargo_release_date = embargo_release_date
    self.visibility_during_embargo = visibility_during_embargo
    self.visibility_after_embargo = visibility_after_embargo
    self.batch_id = batch_id
    self.saved = []
    self.denied = []
  end

  def run
    batch = Batch.find_or_create(self.batch_id)
    user = User.find_by_user_key(self.login)
    batch.generic_files.each do |gf|
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
    date_created = file_attributes[:date_created]
    year_created  = date_created[/(\d\d\d\d)/,0] unless date_created.nil? || date_created.blank?
    gf.year_created = year_created
    collections = file_attributes["hasCollectionId"]
    has_collection = []
    if !collections.empty?
      collections.each do |id|
        c = Collection.find(id)
        c.add_member_ids [gf.id]
        c.save
        has_collection << c.title
      end
    end
    gf.hasCollection = has_collection
    if (trid.present? && trid[gf.id])
      gf.trid = trid[gf.id]
    elsif (ser.present? && ser[gf.id])
      gf.ser = ser[gf.id]
    end
    gf.visibility = visibility unless visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
    if visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      gf.apply_embargo(embargo_release_date, visibility_during_embargo, visibility_after_embargo)
    end
    save_tries = 0
    begin
      ark_identifier = Ezid::Identifier.create(id: Ezid::Client.config.default_shoulder + gf.id)
      unless ark_identifier.nil?  
        ark_identifier.target = Rails.application.config.ezid_url + gf.id
        
        unless gf.title.nil?
          ark_identifier.datacite_title = gf.title.join(";")
        end

        unless gf.creator.nil? 
          ark_identifier.datacite_creator = gf.creator.join(";")
        end

        if gf.year_created.nil?
          ark_identifier.datacite_publicationyear = (:unav)
        else
          ark_identifier.datacite_publicationyear = gf.year_created
        end

        unless gf.resource_type[0].nil?
          ark_identifier.datacite_resourcetype = Sufia.config.ark_resource_types[gf.resource_type[0]]
        end

        ark_identifier.save

        gf.ark_created = "true"
        gf.ark_id = ark_identifier.id
      else
        gf.ark_created = "false"
      end

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
