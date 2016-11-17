require 'spec_helper'

describe Hydranorth::Forms::GenericFileEditForm do
  describe "#terms" do
    it "should return a list" do
      expect(Hydranorth::Forms::GenericFileEditForm.terms).to eq([:title, :creator, :contributor, :subject, :resource_type, :language, :spatial, :temporal, :description, :date_created, :doi, :license, :rights, :is_version_of, :source, :related_url, :belongsToCommunity, :hasCollectionId ])
    end

  end


end
