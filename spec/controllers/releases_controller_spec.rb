require 'spec_helper'

describe ReleasesController do
  context "#index" do
    it "is successful" do
      get :index
      response.should be_success
    end

    it "find the releases" do
      Release.should_receive(:find_with_params)
      get :index
    end

    it "assigns releases" do
      release = mock_model(Release)
      Release.should_receive(:find_with_params).and_return([release])
      get :index
      assigns[:releases].should == [release]
    end

    it "renders the index template" do
      get :index
      response.should render_template('releases/index')
    end

    context "with xml" do
      it "is successful" do
        get :index, :format => 'xml'
        response.should be_success
      end

      it "renders xml" do
        get :index, :format => 'xml'
        response.headers['Content-Type'].should eql('application/xml; charset=utf-8')
      end
    end
  end
end
