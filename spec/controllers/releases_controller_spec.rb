require 'spec_helper'

describe ReleasesController do
  describe "#index" do
    it "is successful" do
      get 'index'
      response.should be_success
    end

    it "find the releases" do
      Release.should_receive(:find_with_params)
      get 'index'
    end

    it "initializes a new release" do
      release = mock_model(Release)
      Release.stub(:new).and_return(release)
      get 'index'
      assigns[:release].should == release
    end

    it "assigns releases" do
      release = mock_model(Release)
      Release.stub(:find_with_params).and_return([release])
      get 'index'
      assigns[:releases].should == [release]
    end

    it "renders the index template" do
      get 'index'
      response.should render_template('releases/index')
    end
  end
end
