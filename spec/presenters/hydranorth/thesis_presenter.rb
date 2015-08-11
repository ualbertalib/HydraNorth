require 'spec_helper'

describe Hydranorth::ThesisPresenter do
  describe ".terms" do
    it "should return a list" do
      expect(described_class.terms).to eq([:title, :alternative_title, :subject, :resource_type, :degree_grantor, :dissertant, :supervisor, :committee_member, :department, :specialization, :date_submitted, :date_accepted, :graduation_date, :thesis_name, :thesis_level, :abstract, :language, :rights, :is_version_of])
    end
  end
end
  

