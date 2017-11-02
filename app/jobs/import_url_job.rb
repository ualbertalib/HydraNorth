require 'net/https'
require 'uri'
require 'tempfile'

class ImportUrlJob < ActiveFedoraIdBasedJob
  def queue_name
  end

  def run
  end

  def copy_remote_file(_import_url, f)
  end

  def job_user
  end
end
