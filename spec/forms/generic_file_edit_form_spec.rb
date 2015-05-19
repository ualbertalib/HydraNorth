require 'spec_helper'

describe Hydranorth::Forms::GenericFileEditForm do
  subject { described_class.new(GenericFile.new) }

  describe "#terms" do
    it "should return a list" do
      expect(subject.terms).to eq([:title, :creator, :contributor, :subject, :resource_type, :language, :spatial, :temporal, :description, :date_created, :license, :is_version_of, :source, :related_url ])
    end

  end


end
