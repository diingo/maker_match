require 'spec_helper'

describe GladiatorMatch::FindUser do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:interest_2) { GladiatorMatch.db.create_interest(name: 'java', expertise: 'beginner')}

  let(:luigi) {
    GladiatorMatch.db.create_user(
      :first_name => 'Luigi',
      :last_name => 'Mario',
      :email => 'luigi@example.com',
      :github_login => 'luigi_mario',
      :interests => [interest_1]
    )
  }

  let(:peach) {
    GladiatorMatch.db.create_user(
      :first_name => 'Peach',
      :last_name => 'Peach',
      :email => 'peach@example.com',
      :github_login => 'peach',
      :interests => [interest_1]
    )
  }

  let(:result) { described_class.run(@params) }

  before do
    GladiatorMatch.db.clear_everything
    @params = { location: '78703', interest: interest_1 }
    Geocoder.stub(:coordinates).with('78703').and_return([30.2915328, -97.76883579999999])
  end

  context 'failure' do
    it "ensures location searched for exists if given" do
        @params[:location] = 'Felony Land'
        # note that this stub might be overriden by the before block stub
        # such that this test is passing because of @params[:location] = 'Felony Land'
        Geocoder.stub(:coordinates).with('Felony Land').and_return(nil)

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_location)
    end

    it "ensures that the interest searched for  is valid" do
      @params[:interest] = ''

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_interest)
    end

    it "ensures that a user with the interest exists" do
      @params[:interest] = interest_2

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:no_user_with_that_interest)
    end
  end

  context 'success' do
    xit 'finds users with the matching qualities' do
      expect(result.success?).to eq(true)
      expect(result.users).to be_a(Array)
      expect(result.users.map(&:first_name)).to include('Luigi', 'Peach')
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