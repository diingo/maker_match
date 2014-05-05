require 'spec_helper'

describe GladiatorMatch::FindUser, pending: true do

  let(:result) { described_class.run(@params) }
  before do

  end
  context 'failure' do
    xit "ensures location searched for exists" do
      VCR.use_cassette('invalid_location') do
        coords = Geocoder.coordinates('112 Mario Cart World, Austin, Tx')
        expect(coords).to be_nil

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_location)
      end
    end
  end
end

  # describe '.get_repo_data' do
  #   it "gets back an array of commits from GitHub" do
  #     VCR.use_cassette('clamstew_matchsetter_repo') do
  #       expect(GHFeed::RepoInfo.get_repo_data('clamstew', 'matchsetter').class).to eq(Array)
  #     end
  #   end
  # end