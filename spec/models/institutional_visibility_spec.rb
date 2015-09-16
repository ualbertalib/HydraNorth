require 'spec_helper'

describe Hydranorth::AccessControls::InstitutionalVisibility, :type => :model do

  before do
    class TestClass < ActiveFedora::Base
      include Hydranorth::AccessControls::InstitutionalVisibility
    end
  end

  after { Object.send(:remove_const, :TestClass) }

  subject { TestClass.new}

  it 'should raise an error if set to a non-existant visibility' do
    expect { subject.visibility = 'asdf'}.to raise_error ArgumentError
  end

  it 'should allow visibility to be restricted to a known institution' do
    expect { subject.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA }.not_to raise_error
    expect(subject.institutional_visibility?).to be true
    expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
  end

  it 'should not continue to list an institution as a read group when set to open visibility' do
    subject.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be true
    subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
    expect(subject.read_groups).not_to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be false
  end

  it 'should not continue to list an institution as a read group when set to authenticated visibility' do
    subject.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be true
    subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
    expect(subject.read_groups).not_to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be false
  end

  it 'should not continue to list an institution as a read group when set to private visibility' do
    subject.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be true
    subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    expect(subject.read_groups).to be_empty
    expect(subject.read_groups).not_to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    expect(subject.institutional_visibility?).to be false
  end

end
