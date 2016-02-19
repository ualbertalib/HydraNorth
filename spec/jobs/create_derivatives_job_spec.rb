require 'spec_helper'

describe CreateDerivativesJob do
  before do
    @ffmpeg_enabled = Sufia.config.enable_ffmpeg
    Sufia.config.enable_ffmpeg = true
    @generic_file = GenericFile.create { |gf| gf.apply_depositor_metadata('dittest@ualberta.ca') }
  end

  after do
    Sufia.config.enable_ffmpeg = @ffmpeg_enabled
  end

  subject { CreateDerivativesJob.new(@generic_file.id) }

  describe 'thumbnail generation' do
    before do
      @generic_file.add_file(File.open(fixture_path + '/' + file_name), path: 'content', original_name: file_name, mime_type: mime_type)
      allow_any_instance_of(GenericFile).to receive(:mime_type).and_return(mime_type)
      @generic_file.save!
    end
    context 'with a video (.avi) file', unless: $in_travis do
      let(:mime_type) { 'video/avi' }
      let(:file_name) { 'countdown.avi' }

      it 'lacks a thumbnail' do
        expect(@generic_file.thumbnail).not_to have_content
      end

      it 'generates a thumbnail on job run', :integration => true do
        subject.run
        @generic_file.reload
        expect(@generic_file.thumbnail).to have_content
        expect(@generic_file.thumbnail.mime_type).to eq('image/jpeg')
      end
    end
  end
end
