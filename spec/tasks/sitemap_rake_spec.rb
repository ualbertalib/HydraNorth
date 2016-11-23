require 'spec_helper'

describe "sitemap:generate", type: :task do
  before :all do
    load_rake_environment('tasks/sitemap')
    ENV["LOCATION"] = "#{Rails.root}/tmp"
    Timecop.freeze
  end

  let(:user) { FactoryGirl.create(:jill) }
  let!(:private_file) do
    GenericFile.new do |f|
      f.title = ['private']
      f.read_groups = ['private']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end
  let!(:broken_file) do
    GenericFile.new do |f|
      f.title = ['broken']
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end
  let!(:missing_hash_file) do
    GenericFile.new do |f|
      f.title = ['missing hash']
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.save!
      allow(f.characterization).to receive(:digest).and_return nil
    end
  end
  let!(:public_file) do
    GenericFile.new do |f|
      f.title = ['public']
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.save!
      f.characterize
    end
  end
  let!(:collection) do
    Collection.new( title: "collection") do |c|
      c.apply_depositor_metadata(user.user_key)
      c.save!
    end
  end

  after(:all) do
    GenericFile.delete_all
    Collection.delete_all
    Timecop.return
  end

  it "should create sitemap.xml which contains a file, collection and ommits the broken and private objects" do
    allow(GenericFile).to receive(:find).and_call_original
    allow(GenericFile).to receive(:find).with(broken_file.id) { raise ActiveFedora::ActiveFedoraError, "Model mismatch. Expected GenericFile. Got: ActiveFedora::Base>" }
    allow(GenericFile).to receive(:find).with(missing_hash_file.id).and_return missing_hash_file

    expect(Rails.logger).to receive(:error).with("id:#{broken_file.id} threw 'Model mismatch. Expected GenericFile. Got: ActiveFedora::Base>' and it was not included in the sitemap.xml")
    expect(Rails.logger).to receive(:error).with("id:#{missing_hash_file.id} threw 'undefined method `first' for nil:NilClass' and it was not included in the sitemap.xml")

    run_rake_task("sitemap:generate")

    expect(File).to exist("#{Rails.root}/tmp/sitemap.xml")
    file = File.read("#{Rails.root}/tmp/sitemap.xml")
    expect(file).to include Time.now.iso8601
    expect(file).to include public_file.id
    expect(file).to include collection.id
    expect(file).not_to include private_file.id
    expect(file).not_to include broken_file.id
    expect(file).not_to include missing_hash_file.id
  end
end
