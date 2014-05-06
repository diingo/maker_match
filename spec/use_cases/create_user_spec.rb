require 'spec_helper'

describe GladiatorMatch::CreateUser do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:interest_2) { GladiatorMatch.db.create_interest(name: 'java', expertise: 'intermediate')}
  let(:result) { described_class.run(@params) }
  before do
    @params = { first_name: 'Plum', last_name: 'Pits', github_login: 'plum_pits', location: '77478', interests: [interest_1, interest_2]}
  end

  context 'error handling' do
    it 'ensures user is created with valid github_login - not nil or blank' do
      VCR.use_cassette('valid_location') do
        # default github_login is '' so we don't have to worry about nil
        @params[:github_login] = ''
        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_login)
      end
    end

    xit 'ensures user is created with valid interests' do
      VCR.use_cassette('valid_location') do
        @params[:interests] = ''
        result = described_class.run(@params)

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_interest)

        @params[:interests] = []
        result = described_class.run(@params)
        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_interest)
      end
    end

    it 'ensures user is created with valid location' do
      VCR.use_cassette('invalid_location') do
        # some invalid addresses don't return nil
        # ex, 101 Mario Kart World, Austin, Tx just gets coords austin, tx

        @params[:location] = 'Felony Land'

        expect(result.success?).to eq(false)
        expect(result.error).to eq(:invalid_location)
      end
    end

    it 'ensures first and last names are not blank' do
      VCR.use_cassette('valid_location') do
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
  end

  context 'success' do
    xit 'creates a user' do

      expect(result.success?).to eq(true)
      expect(result.user.first_name).to eq('Plum')
      expect(result.user.github_login).to eq('plum_pits')
    end
  end
end