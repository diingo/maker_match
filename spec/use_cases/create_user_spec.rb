require 'spec_helper'

describe GladiatorMatch::CreateUser do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:interest_2) { GladiatorMatch.db.create_interest(name: 'java', expertise: 'intermediate')}
  let(:result) { described_class.run(@params) }

  before do
    @params = { first_name: 'Plum', last_name: 'Pits', github_login: 'plum_pits', location: '77478', remote: true, interests: [interest_1, interest_2]}
    Geocoder.stub(:coordinates).with('77478').and_return([29.6185208, -95.6090009])
  end

  context 'error handling' do
    it 'ensures user is created with valid github_login - not nil or blank' do
        # default github_login is '' so we don't have to worry about nil
        @params[:github_login] = ''
        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_login)
    end

    it 'ensures user is created with valid interests' do
        @params[:interests] = ''
        result = described_class.run(@params)

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_interest)

        @params[:interests] = []
        result = described_class.run(@params)
        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_interest)
    end

    it 'ensures user is created with valid location' do
        Geocoder.should_receive(:coordinates).with('Felony Land').and_return(nil)
        # some invalid addresses don't return nil
        # ex, 101 Mario Kart World, Austin, Tx just gets coords austin, tx

        @params[:location] = 'Felony Land'

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_location)
    end

    it 'ensures first and last names are not blank' do
        @params[:first_name] = ''
        result = described_class.run(@params)

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_name)

        @params[:last_name] = ''
        result = described_class.run(@params)
        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_name)
    end
  end

  context 'success' do
    it 'creates a user' do

      expect(result.success?).to eq(true)
      expect(result.user.first_name).to eq('Plum')
      expect(result.user.github_login).to eq('plum_pits')
      expect(result.user.remote).to eq(true)
      expect(result.user.interests).to be_a(Array)
      expect(result.user.interests.map(&:name)).to include('haskell', 'java')
      expect(result.user.latitude).to eq(29.6185208)
      expect(result.user.longitude).to eq(-95.6090009)
      expect(result.user.location).to eq('77478')
    end
  end
end