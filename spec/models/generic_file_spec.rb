require 'spec_helper'

describe GenericFile, :type => :model do

  describe "attributes" do
    it "should have a fedora3 foxml datastream" do
      subject.add_file(File.open(fixture_path + '/foxml.xml'), path: 'fedora3foxml', original_name: 'foxml.xml')
      expect(subject.fedora3foxml).to be_kind_of Fedora3FoxmlDatastream
    end
  end

  it "should be indexed by the Hydranorth::GenericFileIndexingService" do
    expect(GenericFile.indexer).to be Hydranorth::GenericFileIndexingService
  end

  describe "metadata" do
    it "should have descriptive metadata" do
      expect(subject).to respond_to(:relative_path)
      expect(subject).to respond_to(:depositor)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:part_of)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:date_uploaded)
      expect(subject).to respond_to(:date_modified)
      expect(subject).to respond_to(:subject)
      expect(subject).to respond_to(:language)
      expect(subject).to respond_to(:license)
      expect(subject).to respond_to(:resource_type)
      expect(subject).to respond_to(:trid)
      expect(subject).to respond_to(:ser)
      expect(subject).to respond_to(:temporal)
      expect(subject).to respond_to(:spatial)
      expect(subject).to respond_to(:is_version_of)
      expect(subject).to respond_to(:belongsToCommunity)
      expect(subject).to respond_to(:doi)
      expect(subject).to respond_to(:aasm_state)
    end

    it "#belongsToCommunity? should check if object belongs to any community" do
      subject.belongsToCommunity = ["abcsdfs"]
      subject.save
      expect(subject.belongsToCommunity?).to be true
    end

  end

  describe "thesis_metadata" do
    it "should have thesis metadata" do
      expect(subject).to respond_to(:degree_grantor)
      expect(subject).to respond_to(:dissertant)
      expect(subject).to respond_to(:supervisor)
      expect(subject).to respond_to(:committee_member)
      expect(subject).to respond_to(:department)
      expect(subject).to respond_to(:specialization)
      expect(subject).to respond_to(:date_submitted)
      expect(subject).to respond_to(:date_accepted)
      expect(subject).to respond_to(:graduation_date)
      expect(subject).to respond_to(:alternative_title)
      expect(subject).to respond_to(:thesis_name)
      expect(subject).to respond_to(:thesis_level)
      expect(subject).to respond_to(:proquest)
      expect(subject).to respond_to(:abstract)

    end
  end

  describe '#append_metadata', :integration => true do

    before  do
      # TODO: Don't use a before each, use a let instead
      @myfile = GenericFile.new(id: SecureRandom.hex)
      @myfile.add_file(File.open(fixture_path + '/sufia/sufia_test4.pdf', 'rb').read, path: 'content', original_name: 'sufia_test4.pdf', mime_type: 'application/pdf')
      @myfile.apply_depositor_metadata('mjg36')
      # characterize method saves
      @myfile.characterize
      @myfile.reload
    end

    context 'with fulltext disabled (by default)' do
      it 'should not call extract_content' do
        expect(@myfile).not_to receive(:extract_content)
        @myfile.append_metadata
      end
    end

    context 'with fulltext enabled' do
      before { Rails.configuration.enable_fulltext = true }
      after { Rails.configuration.enable_fulltext = false }
      it 'should call extract_content' do
        expect(@myfile).to receive(:extract_content).once
        @myfile.append_metadata
      end
    end

  end

  describe "to_solr" do
    let(:community) {FactoryGirl.create :collection}
    before do
      allow(subject).to receive(:id).and_return('stubbed_id')
      subject.part_of = ["Arabiana"]
      subject.contributor = ["Mohammad"]
      subject.creator = ["Allah"]
      subject.title = ["The Work"]
      subject.trid = "123"
      subject.description = ["The work by Allah"]
      subject.date_created = "1200-01-01"
      subject.date_uploaded = Date.parse("2011-01-01")
      subject.date_modified = Date.parse("2012-01-01")
      subject.subject = ["Theology"]
      subject.language = "Arabic"
      subject.license = "Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"
      subject.resource_type = ["Book"]
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = ["JPEG Image"]
      subject.full_text.content = 'abcxyz'
      subject.spatial = ["Medina, Saudi Arabia"]
      subject.temporal = ["1200"]
      subject.fedora3uuid = "uuid:f18e0d92-9474-478d-b0e5-0b50c866dea3"
      subject.fedora3handle = "http://hdl.handle.net/10402/era.23258"
      subject.belongsToCommunity = [community.id]
      subject.doi = 'doi:10.5072/FKEXAMPLE'
      subject.aasm_state = 'available'
    end

    it "supports to_solr" do
      local = subject.to_solr
      expect(local[Solrizer.solr_name("part_of")]).to be_nil
      expect(local[Solrizer.solr_name("date_uploaded")]).to be_nil
      expect(local[Solrizer.solr_name("date_modified")]).to be_nil
      expect(local[Solrizer.solr_name("date_uploaded", :stored_sortable, type: :date)]).to eq '2011-01-01T00:00:00Z'
      expect(local[Solrizer.solr_name("date_modified", :stored_sortable, type: :date)]).to eq '2012-01-01T00:00:00Z'
      expect(local[Solrizer.solr_name("license")]).to eq ["Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"]
      expect(local[Solrizer.solr_name("related_url")]).to eq ["http://example.org/TheWork/"]
      expect(local[Solrizer.solr_name("contributor")]).to eq ["Mohammad"]
      expect(local[Solrizer.solr_name("creator")]).to eq ["Allah"]
      expect(local[Solrizer.solr_name("title")]).to eq ["The Work"]
      expect(local[Solrizer.solr_name("title", :facetable)]).to eq ["The Work"]
      expect(local[Solrizer.solr_name("description")]).to eq ["The work by Allah"]
      expect(local[Solrizer.solr_name("subject")]).to eq ["Theology"]
      expect(local[Solrizer.solr_name("language")]).to eq ["Arabic"]
      expect(local[Solrizer.solr_name("date_created")]).to eq ["1200-01-01"]
      expect(local[Solrizer.solr_name("resource_type")]).to eq ["Book"]
      expect(local[Solrizer.solr_name("file_format")]).to eq "jpeg (JPEG Image)"
      expect(local[Solrizer.solr_name("fedora3uuid")]).to eq ["uuid:f18e0d92-9474-478d-b0e5-0b50c866dea3"]
      expect(local[Solrizer.solr_name("fedora3handle")]).to eq ["http://hdl.handle.net/10402/era.23258"]
      expect(local[Solrizer.solr_name("spatial")]).to eq ["Medina, Saudi Arabia"]
      expect(local[Solrizer.solr_name("temporal")]).to eq ["1200"]
      expect(local[Solrizer.solr_name("mime_type")]).to eq ["image/jpeg"]
      expect(local['all_text_timv']).to eq('abcxyz')
      expect(local[Solrizer.solr_name('belongsToCommunity')]).to eq [community.id]
      expect(local[Solrizer.solr_name('doi', :symbol)]).to eq ['doi:10.5072/FKEXAMPLE']
      expect(local[Solrizer.solr_name('doi_without_label', :symbol)]).to eq ['10.5072/FKEXAMPLE']
      expect(local[Solrizer.solr_name('aasm_state')]).to eq ['available']
    end
  end

  describe 'Thesis' do
    let(:community) {FactoryGirl.create :collection}

    before do
      allow(subject).to receive(:id).and_return('stubbed_id')
      subject.part_of = ["Arabiana"]
      subject.contributor = ["Mohammad"]
      subject.dissertant = "Allah"
      subject.title = ["The Work"]
      subject.trid = "123"
      subject.abstract = "The work by Allah"
      subject.date_created = "1200-01-01"
      subject.date_uploaded = Date.parse("2011-01-01")
      subject.date_modified = Date.parse("2012-01-01")
      subject.subject = ["Theology"]
      subject.language = "Arabic"
      subject.license = "Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"
      subject.resource_type = ["Thesis"]
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = ["JPEG Image"]
      subject.full_text.content = 'abcxyz'
      subject.spatial = ["Medina, Saudi Arabia"]
      subject.temporal = ["1200"]
      subject.fedora3uuid = "uuid:f18e0d92-9474-478d-b0e5-0b50c866dea3"
      subject.fedora3handle = "http://hdl.handle.net/10402/era.23258"
      subject.belongsToCommunity = [community.id]
    end

    it 'should be a thesis' do
      expect(subject.thesis?).to be true
    end


    it 'should index the dissertant as creator' do
      solr_doc = subject.to_solr

      expect(solr_doc[Solrizer.solr_name('creator')]).to eq subject.dissertant
    end

    it 'should index the abstract as description' do
      solr_doc = subject.to_solr

      expect(solr_doc[Solrizer.solr_name('description')]).to eq subject.abstract
    end
  end


  describe 'visibility' do
    it 'should include institutional visibility' do
      expect(GenericFile.included_modules.include? Hydranorth::AccessControls::InstitutionalVisibility).to be true
    end
  end

  describe 'callbacks for preservation' do
    let(:generic_file) do
      FactoryGirl.build(:generic_file, title: ['Test Title'], creator: ['John Doe'], resource_type: ['Book']) do |gf|
                          gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                          gf.apply_depositor_metadata('ditest@example.com')
                        end
    end

    before(:each) do
      # clear out the test preservation queue for consistent results
      $redis.del Hydranorth::PreservationQueue::QUEUE_NAME
    end

    after(:all) do
      $redis.del Hydranorth::PreservationQueue::QUEUE_NAME
      Timecop.return
      cleanup_jetty
    end

    it 'should add the noid with the correct score for a new item to the preservation queue' do
      now = Time.now
      Timecop.freeze(now)


      generic_file.save

      noid, score = $redis.zrange(Hydranorth::PreservationQueue::QUEUE_NAME, 0, -1, with_scores: true)[0]

      expect(noid).to eq generic_file.id
      expect(score).to be_within(0.5).of now.to_f

      Timecop.return
    end

    it 'should end up with the queue only having a noid once after multiple saves of the same item' do
      now = Time.now
      Timecop.freeze(now)

      generic_file.save

      intermediate_save_time = now + 1.minute
      Timecop.travel(intermediate_save_time)
      generic_file.save

      final_save_time = intermediate_save_time + 3.minutes
      Timecop.travel(final_save_time)
      generic_file.save

      queue_count = $redis.zcard Hydranorth::PreservationQueue::QUEUE_NAME
      expect(queue_count).to eq 1

      noid, score = $redis.zrange(Hydranorth::PreservationQueue::QUEUE_NAME, 0, -1, with_scores: true)[0]
      expect(noid).to eq generic_file.id
      expect(score).to be_within(0.5).of final_save_time.to_f

      Timecop.return
    end

    it 'should end up with noids in the queue in the correct temporal order' do
      files = []
      4.times do
        files << FactoryGirl.build(:generic_file) do |gf|
          gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          gf.apply_depositor_metadata('ditest@example.com')
        end
      end

      now = Time.now
      Timecop.freeze(now)

      # this is all maybe a bit too "there's nothing up my sleeve" about noid orders, but c'est la vie
      files = files.shuffle

      files[0].save

      now += 2.minutes
      Timecop.travel(now)
      files[3].save

      now -= 6.minutes
      Timecop.travel(now)
      files[1].save

      now += 2.hours
      Timecop.travel(now)
      files[2].save

      save_order = [files[1], files[0], files[3], files[2]]

      queue = $redis.zrange(Hydranorth::PreservationQueue::QUEUE_NAME, 0, -1, with_scores: false)

      expect(save_order.map(&:id)).to match_array(queue)
      Timecop.return
    end

  end

  describe 'callbacks for doi' do
    include ActiveJob::TestHelper

    let(:new_generic_file) do
      FactoryGirl.build(:generic_file, title: ['Test Title'],
                                        creator: ['John Doe'],
                                        resource_type: ['Book']) do |gf|
                                          gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                                          gf.apply_depositor_metadata('ditest@example.com')
                                        end
    end

    let(:generic_file) do
      FactoryGirl.create(:generic_file, title: ['Test Title'],
                                        creator: ['John Doe'],
                                        resource_type: ['Book']) do |gf|
                                          gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                                          gf.apply_depositor_metadata('ditest@example.com')
                                          gf.aasm_state = 'available'
                                          gf.doi = 'doi:10.5072/FKEXAMPLE'
                                        end
    end

    after(:each) do
      clear_enqueued_jobs
    end

    it 'should not mint a new file that is private' do
      new_generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      new_generic_file.save
      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('not_available')
      expect(enqueued_jobs.count).to eq(0)
    end

    it 'should mint a new file that is public' do
      new_generic_file.save
      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('unminted')
      expect(enqueued_jobs.count).to eq(1)
    end

    it 'should mint a new file that has a dissertant instead of a creator' do
      new_generic_file.creator = nil
      new_generic_file.dissertant = 'John Doe'
      new_generic_file.save

      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('unminted')
      expect(enqueued_jobs.count).to eq(1)
    end

    it 'should not mint a new file that is public if #skip_handle_doi_states is true' do
      new_generic_file.skip_handle_doi_states = true
      new_generic_file.save
      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('not_available')
      expect(new_generic_file.skip_handle_doi_states).to eq(false) # rollsback to false
      expect(enqueued_jobs.count).to eq(0)
    end

    it 'should update doi when file is public and a changes to doi field happen' do
      generic_file.title = ['Diff Title']
      generic_file.save

      generic_file.reload
      expect(generic_file.aasm_state).to eq('awaiting_update')
      expect(enqueued_jobs.count).to eq(1)
    end

    it 'should not update doi when file is public and changes to non doi fields happen' do
      generic_file.language = 'Arabic'
      generic_file.save

      generic_file.reload
      expect(generic_file.aasm_state).to eq('available')
      expect(enqueued_jobs.count).to eq(0)
    end

    it 'should not update doi when file changes visibility between public visibilities' do
      generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      generic_file.save

      generic_file.reload
      expect(generic_file.aasm_state).to eq('available')
      expect(enqueued_jobs.count).to eq(0)
    end

    it 'should update doi when file changes visibility from public to private' do
      generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      generic_file.save

      generic_file.reload
      expect(generic_file.aasm_state).to eq('awaiting_update')
      expect(enqueued_jobs.count).to eq(1)
    end

    it 'should update doi when file changes visibility from private to public' do
      new_generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      new_generic_file.aasm_state = 'not_available'
      new_generic_file.doi = 'doi:10.5072/FKEXAMPLE'
      new_generic_file.save

      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('not_available')
      expect(enqueued_jobs.count).to eq(0)

      new_generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      new_generic_file.save
      new_generic_file.reload
      expect(new_generic_file.aasm_state).to eq('awaiting_update')
      expect(enqueued_jobs.count).to eq(1)
    end

    it 'should not withdraw doi if file has no doi and is destroyed' do
      new_generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      new_generic_file.save

      new_generic_file.destroy
      expect(enqueued_jobs.count).to eq(0)
    end

    it 'should withdraw doi if file has doi and  is destroyed' do
      generic_file.destroy
      expect(enqueued_jobs.count).to eq(1)
    end
  end

end
