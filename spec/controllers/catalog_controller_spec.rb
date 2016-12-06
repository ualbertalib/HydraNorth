require 'spec_helper'

describe CatalogController, type: :controller do
  def solr_field name
    Solrizer.solr_name(name, :stored_searchable, type: :string)
  end

  def advanced_author_query
    [Solrizer.solr_name("contributor", :store_searchable), Solrizer.solr_name("creator", :stored_searchable)].join(" ")
  end

  def advanced_subject_query
    [Solrizer.solr_name("subject", :store_searchable), Solrizer.solr_name("spatial", :stored_searchable), Solrizer.solr_name("temporal", :stored_searchable)].join(" ")
  end

  def year_created_facet
    Solrizer.solr_name("year_created", :facetable, type: :date)
  end

  before :all do
    cleanup_jetty

    @gf1 = GenericFile.new(title: ['Test Document PDF'], filename: ['test.pdf'], creator: ['Contrib2'], read_groups:['public']) do |f|
      f.apply_depositor_metadata('qw1')
      f.save
    end


    GenericFile.new(title: ['Test 2 Document'], filename: ['test2.doc'], contributor: ['Contrib2'], read_groups:['public']) do |f|
      f.apply_depositor_metadata('qw1')
      f.save
    end

    GenericFile.new do |f|
      f.title = ['titletitle']
      f.filename = ['filename.filename']
      f.date_created = '1900/12/31'
      f.read_groups = ['public']
      f.spatial = ["Edmonton"]
      f.language = "EnglishEnglish"
      f.creator = ["creator1"]
      f.contributor = ["contributor1"]
      f.temporal = ["temporaltemporal"]
      f.subject = ["subjectsubject"]
      f.department = ["Department of Departments"]
      f.supervisor = ["SuperDuperVisor"]
      f.committee_member = ["Chairperson", "CEO", "Random Bystander"]
      f.resource_type = ["resource_typeresource_type"]
      f.description = ["descriptiondescription"]
      f.format_label = ["format_labelformat_label"]
      f.full_text.content = "full_textfull_text"
      f.apply_depositor_metadata('qw1')
      f.save
    end
  end

  after :all do
    cleanup_jetty
  end

  describe "#catalog" do
    describe "term search" do
      it "should find pdf files" do
        xhr :get, :index, q: "pdf"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('Test Document PDF')
      end

      it 'should find a file by NOID' do
        xhr :get, :index, q: @gf1.id

        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('Test Document PDF')
      end

      it 'should find a file by department' do
        xhr :get, :index, q: "Department of Departments"

        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end

      it 'should find a file by supervisor' do
        xhr :get, :index, q: "SuperDuperVisor"

        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end

      it 'should find a file by committee members' do
        xhr :get, :index, q: "Random Bystander"

        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end

      it "should find a file by title" do
        xhr :get, :index, q: "titletitle"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("title"))[0]).to eql('titletitle')
      end

      it "should find a file by subject" do
        xhr :get, :index, q: "subjectsubject"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("subject"))[0]).to eql('subjectsubject')
      end

      it "should find a file by creator" do
        xhr :get, :index, q: "creator1"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("creator"))[0]).to eql('creator1')
      end

      it "should find a file by contributor" do
        xhr :get, :index, q: "contributor1"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("contributor"))[0]).to eql('contributor1')
      end

      it "should find a file by temporal" do
        xhr :get, :index, q: "temporaltemporal"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("temporal"))[0]).to eql('temporaltemporal')
      end

      it "should find a file by spatial" do
        xhr :get, :index, q: "edmonton"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("spatial"))[0]).to eql('Edmonton')
      end

      it "should find a file by language" do
        xhr :get, :index, q: "EnglishEnglish"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("language"))[0]).to eql('EnglishEnglish')
      end

      it "should find a file by resource_type" do
        xhr :get, :index, q: "resource_typeresource_type"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("resource_type"))[0]).to eql('resource_typeresource_type')
      end

      it "should find a file by format_label" do
        xhr :get, :index, q: "format_labelformat_label"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("file_format"))[0]).to eql('format_labelformat_label')
      end

      it "should find a file by description" do
        xhr :get, :index, q: "descriptiondescription"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
        expect(assigns(:document_list)[0].fetch(solr_field("description"))[0]).to eql('descriptiondescription')
      end

      it "should find a file by full_text" do
        xhr :get, :index, q: "full_textfull_text"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end

      it "should do author search in advanced" do
        xhr :get, :index, q: "author=Contrib2"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(2)
      end
    end

    describe "year_created facet search" do
      it "should find facet files" do
        xhr :get, :index, q: "{f=#{year_created_facet}}1900"
        expect(response).to be_success
        expect(response).to render_template('catalog/index')
        expect(assigns(:document_list).count).to eql(1)
      end
    end
  end

end
