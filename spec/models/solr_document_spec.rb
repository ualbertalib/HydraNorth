require 'spec_helper'

describe SolrDocument, type: :model do

  describe "date_created" do
    before do
      subject['date_created_tesim'] = '03/14/2013'
    end
    it "should be a string" do
      expect(subject.date_created).to eq '03/14/2013'
    end
  end

  describe 'date_created?' do
    it 'should return false if no date_created is set' do
      subject['date_created_tesim'] = nil
      expect(subject.date_created?).to eq false 
    end
    it 'should return true if date_created is set' do
      subject['date_created_tesim'] = '03/14/2013'
      expect(subject.date_created?).to eq true
    end

  end


end
