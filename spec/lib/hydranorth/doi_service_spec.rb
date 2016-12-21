require 'spec_helper'

describe Hydranorth::DOIService do
  let(:example_doi_id) { 'doi:10.5072/FK2JQ1003W' }
  let(:generic_file) do
    FactoryGirl.create(:generic_file, title: ['Test Title'],
                                      creator: ['John Doe'],
                                      resource_type: ['Book'])
  end

  describe '#create' do
    it 'should fail DOI if generic file is not valid' do
      VCR.use_cassette('ezid_minting') do
        ezid_identifer = Hydranorth::DOIService.new(generic_file).create
        expect(ezid_identifer).to eq(nil)
      end
    end

    it 'should DOI successfully if generic file is valid' do
      expect(generic_file.doi).to eq(nil)
      VCR.use_cassette('ezid_minting') do
        generic_file.aasm_state = 'unminted'
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        generic_file.save

        ezid_identifer = Hydranorth::DOIService.new(generic_file).create
        expect(ezid_identifer).not_to eq(nil)
        expect(ezid_identifer.datacite_publisher).to eq(Hydranorth::DOIService::PUBLISHER)
        expect(ezid_identifer.datacite_title).to eq('Test Title')
        expect(ezid_identifer.datacite_resourcetype).to eq('Text/Book')
        expect(ezid_identifer.datacite_publicationyear).to eq('(:unav)')
        expect(ezid_identifer.status).to eq(Ezid::Status::PUBLIC)
        expect(ezid_identifer.export).to eq('yes')
        generic_file.reload
        expect(generic_file.doi).not_to eq(nil)
        expect(generic_file.aasm_state).to eq('available')
      end
    end

    it 'should rollback to proper state if EZID fails' do
      expect(generic_file.doi).to eq(nil)
      VCR.use_cassette('ezid_minting_failure') do
        generic_file.aasm_state = 'unminted'
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        generic_file.save!

        expect { Hydranorth::DOIService.new(generic_file).create }.to raise_error(Ezid::Error, 'bad request - password required')

        generic_file.reload

        expect(generic_file.doi).to eq(nil)
        expect(generic_file.aasm_state).to eq('not_available')
        expect(generic_file.skip_handle_doi_states).to eq(false)
      end
    end
  end

  describe '#update' do
    it 'should fail DOI if generic file is not valid' do
      VCR.use_cassette('ezid_updating') do
        ezid_identifer = Hydranorth::DOIService.new(generic_file).update
        expect(ezid_identifer).to eq(nil)
      end
    end

    it 'should successfully update when passing in valid doi and metadata' do
      VCR.use_cassette('ezid_updating') do
        generic_file.aasm_state = 'awaiting_update'
        generic_file.doi = example_doi_id
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        generic_file.title = ['Different Title']
        generic_file.save

        ezid_identifer = Hydranorth::DOIService.new(generic_file).update
        expect(ezid_identifer).not_to eq(nil)
        expect(ezid_identifer.id).to eq(example_doi_id)
        expect(ezid_identifer.status).to eq(Ezid::Status::PUBLIC)
        expect(ezid_identifer.datacite_title).to eq('Different Title')
        expect(ezid_identifer.export).to eq('yes')
        generic_file.reload
        expect(generic_file.aasm_state).to eq('available')
      end
    end

    it 'should successfully update to unavailable when private' do
      VCR.use_cassette('ezid_updating_unavailable') do
        generic_file.aasm_state = 'awaiting_update'
        generic_file.doi = example_doi_id
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        generic_file.save

        ezid_identifer = Hydranorth::DOIService.new(generic_file).update
        expect(ezid_identifer).not_to eq(nil)
        expect(ezid_identifer.id).to eq(example_doi_id)
        expect(ezid_identifer.status).to eq('unavailable | not publicly released')
        expect(ezid_identifer.export).to eq('no')
        generic_file.reload
        expect(generic_file.aasm_state).to eq('not_available')
      end
    end

    it 'should rollback to proper state if EZID fails when private' do
      VCR.use_cassette('ezid_updating_failure') do
        generic_file.aasm_state = 'awaiting_update'
        generic_file.doi = example_doi_id
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        generic_file.save!

        expect { Hydranorth::DOIService.new(generic_file).update }.to raise_error(Ezid::Error, 'bad request - password required')

        generic_file.reload
        expect(generic_file.aasm_state).to eq('available')
        expect(generic_file.skip_handle_doi_states).to eq(false)
      end
    end

    it 'should rollback to proper state if EZID fails when public' do
      VCR.use_cassette('ezid_updating_failure') do
        generic_file.aasm_state = 'awaiting_update'
        generic_file.doi = example_doi_id
        generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        generic_file.save!

        expect { Hydranorth::DOIService.new(generic_file).update }.to raise_error(Ezid::Error, 'bad request - password required')

        generic_file.reload
        expect(generic_file.aasm_state).to eq('not_available')
        expect(generic_file.skip_handle_doi_states).to eq(false)
      end
    end
  end

  describe '.remove' do
    it 'should successfully remove doi by setting status to unavailable ' do
      VCR.use_cassette('ezid_removal') do
        ezid_identifer = Hydranorth::DOIService.remove(example_doi_id)
        expect(ezid_identifer).not_to eq(nil)
        expect(ezid_identifer.id).to eq(example_doi_id)
        expect(ezid_identifer.status).to eq('unavailable | withdrawn')
        expect(ezid_identifer.export).to eq('no')
      end
    end
  end

end
