require 'spec_helper'

describe Hydranorth::Forms::GenericFileEditForm do
  subject { described_class.new(GenericFile.new) }

  describe "#terms" do
    it "should return a list" do
      expect(subject.terms).to eq([:resource_type, :title, :creator, :contributor, :description, :date_created, :license, :subject, :spatial, :temporal, :is_version_of, :source, :related_url, :language ])
    end

  end


end
