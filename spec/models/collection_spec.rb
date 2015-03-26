require 'spec_helper'

describe Collection do

  let(:reloaded_subject) { Collection.find(subject.id) }
  let(:user) { FactoryGirl.create(:user) }
  let(:file) do
    GenericFile.create do |f|
      f.add_file(File.open(fixture_path + '/world.png'), path: 'content', original_name: 'world.png')
      f.apply_depositor_metadata(user.user_key)
    end
  end
  let(:another_collection) { FactoryGirl.create(:collection) }

  before do
    subject.title = 'A title'
    subject.apply_depositor_metadata(user.user_key)
  end

  it 'can be part of a collection' do
    expect(subject.can_be_member_of_collection?(double)).to be true
  end

  it 'can contain another collection' do
    another_collection = FactoryGirl.create(:collection)
    subject.members << another_collection
    expect(subject.members).to eq [another_collection]
  end

  it 'updates solr with ids of its parent collections' do
    another_collection = FactoryGirl.create(:collection)
    another_collection.members << subject
    another_collection.save
    expect(subject.reload.to_solr[Solrizer.solr_name(:collection)]).to eq [another_collection.id]
  end

  it 'cannot contain itself' do
    subject.members << subject
    subject.save
    expect(reloaded_subject.members).to eq []
  end

  it 'returns 0 bytes for empty collection' do
    expect(subject.bytes).to eq 0 
  end

  it 'returns 0 bytes for member collection' do
    subject.members << another_collection
    expect(subject.bytes).to eq 0 
  end

  it 'returns bytes for member file' do
    subject.members << file
    expect(subject.bytes).to eq 4218 
  end

  it 'returns bytes for collections and files' do
    subject.members << another_collection
    subject.members << file
    expect(subject.bytes).to eq 4218 
  end

  it 'returns false for processing?' do
    expect(subject.processing?).to be_falsey
  end
  
  it "should have a fedora3 foxml datastream" do
    subject.add_file(File.open(fixture_path + '/foxml.xml'), path: 'fedora3foxml', original_name: 'foxml.xml')
    expect(subject.fedora3foxml).to be_kind_of Fedora3FoxmlDatastream
  end

end
