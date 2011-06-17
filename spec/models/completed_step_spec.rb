require 'spec_helper'

describe CompletedStep do
  context "checking if all releases have been fetched" do
    before do
      @completed_step = mock_model(CompletedStep)
      CompletedStep.should_receive(:where).with(:step => CompletedStep::ReleasesCollected).and_return(@completed_step)
    end

    context "when they have" do
      it "should be true" do
        @completed_step.should_receive(:count).and_return(1)
        CompletedStep.finished_fetching_releases?.should be_true
      end
    end

    context "when they haven't" do
      it "should be false" do
        @completed_step.should_receive(:count).and_return(0)
        CompletedStep.finished_fetching_releases?.should be_false
      end
    end
  end

  context "checking if all release dates have been updated from Amazon" do
    before do
      @completed_step = mock_model(CompletedStep)
      CompletedStep.should_receive(:where).with(:step => CompletedStep::ReleasesUpdatedFromAmazon).and_return(@completed_step)
    end

    context "when they have" do
      it "should be true" do
        @completed_step.should_receive(:count).and_return(1)
        CompletedStep.finished_updating_releases_from_amazon?.should be_true
      end
    end

    context "when they haven't" do
      it "should be false" do
        @completed_step.should_receive(:count).and_return(0)
        CompletedStep.finished_updating_releases_from_amazon?.should be_false
      end
    end
  end
end
