require 'spec_helper'

describe Hydranorth::SerPresenter do
  describe ".terms" do
    it "should return a list" do
      expect(described_class.terms).to eq([:title, :creator, :contributor, :subject, :resource_type, :ser, :language, :spatial, :temporal, :description, :date_created, :license, :rights, :is_version_of, :source, :related_url])
    end
  end
end
  

