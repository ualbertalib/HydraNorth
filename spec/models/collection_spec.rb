require 'spec_helper'

describe Collection do

  let(:reloaded_subject) { Collection.find(subject.id) }
  let(:user) { FactoryGirl.create(:user) }

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

  it 'returns [] for file_size' do
    expect(subject.file_size).to eq []
  end

  it 'returns false for processing?' do
    expect(subject.processing?).to be_falsey
  end

end
