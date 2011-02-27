require 'spec_helper'

describe CompletedStep do
  context "checking if all album urls have been fetched" do
    context "when they have" do
      it "should be true" do
        CompletedStep.should_receive(:find_by_step).and_return(mock_model(CompletedStep))
        CompletedStep.finished_fetching_album_urls?.should be_true
      end
    end

    context "when they haven't" do
      it "should be false" do
        CompletedStep.should_receive(:find_by_step).and_return(nil)
        CompletedStep.finished_fetching_album_urls?.should be_false
      end
    end
  end
end
