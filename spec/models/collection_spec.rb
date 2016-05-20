require 'spec_helper'
require 'rest-client'

describe Collection do

  let(:reloaded_subject) { Collection.find(subject.id) }
  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:file) do
    GenericFile.create do |f|
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.apply_depositor_metadata(user.user_key)
      f.save
    end
  end
  let(:another_collection) { FactoryGirl.create(:collection) }

  before :each do
    subject.title = 'A title'
    subject.apply_depositor_metadata(user.user_key)
    subject.save
  end

  it 'can be part of a collection' do
    expect(subject.can_be_member_of_collection?(double)).to be true
  end

  it 'can contain another collection' do
    another_collection = FactoryGirl.create(:collection)
    subject.add_members [another_collection]
    subject.save

    expect(subject.materialized_members).to eq [another_collection]
  end

  it 'cannot contain itself' do
    subject.add_member subject
    subject.save
    expect(reloaded_subject.members).to eq []
  end

  it 'returns 0 bytes for empty collection' do
    expect(subject.bytes).to eq 0
  end

  it 'returns 0 bytes for member collection' do
    subject.add_member another_collection
    subject.save
    expect(subject.bytes).to eq 0
  end

  it 'returns bytes for member file' do
    subject.add_member file
    subject.save

    expect(subject.bytes).to eq 4218
  end

  it 'returns bytes for collections and files' do
    subject.add_members [file, another_collection]
    subject.save
    expect(subject.bytes).to eq 4218
  end

  it 'returns false for processing?' do
    expect(subject.processing?).to be_falsey
  end

  it "should have a fedora3 foxml datastream" do
    subject.add_file(File.open(fixture_path + '/foxml.xml'), path: 'fedora3foxml', original_name: 'foxml.xml')
    subject.save
    expect(subject.fedora3foxml).to be_kind_of Fedora3FoxmlDatastream
  end

  it "should allow any registered user to edit an official collection" do
    subject.is_official = true
    subject.save
    expect(subject.edit_groups).to include 'registered'
  end

  it "should not allow registered user to edit an official collection that is admin set" do
    subject.is_official = true
    subject.is_admin_set = true
    subject.save
    expect(subject.edit_groups).not_to include 'registered'
  end

  it "#belongsToCommunity? should check if collection belongs to any community" do
    subject.belongsToCommunity = ["adsfsfsd"]
    subject.save
    expect(subject.belongsToCommunity?).to be true
  end

  it "should not insert a hasCollection_ref instead of hasCollection" do
    subject.add_member_ids [file.id]
    response_code, xml = Hydranorth::RawFedora.get(file.id, '/fcr:export', format: 'jcr/xml')

    expect(response_code).to eq 200

    namespace = xml.collect_namespaces.invert['http://terms.library.ualberta.ca/identifiers/']
    expect(namespace).not_to eq nil

    namespace = namespace.gsub(/xmlns:/, '')

    expect(xml.xpath(%Q|//sv:property[@sv:name="#{namespace}:hasCollection"]|)).not_to be_empty
    expect(xml.xpath(%Q|//sv:property[@sv:name="#{namespace}:hasCollection_ref"]|)).to be_empty
    expect(xml.xpath(%Q|//sv:property[@sv:name="#{namespace}:hasCollection"]|).first.inner_text).to eq 'A title'
  end

end
