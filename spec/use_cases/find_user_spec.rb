require 'spec_helper'

describe GladiatorMatch::FindUser, pending: true do

  (:result) { described_class.run(@params) }
  before do

  end
  context 'failure' do
    it "ensures location searched for exists"
  end
end

  # describe '.get_repo_data' do
  #   it "gets back an array of commits from GitHub" do
  #     VCR.use_cassette('clamstew_matchsetter_repo') do
  #       expect(GHFeed::RepoInfo.get_repo_data('clamstew', 'matchsetter').class).to eq(Array)
  #     end
  #   end
  # end