require 'spec_helper'

describe FindAlbumsJob do
  describe "#perform" do
    it "should generate the releases" do
      MetalArchivesFetcher.should_receive(:generate_releases)
      FindAlbumsJob.new.perform
    end
  end
end
