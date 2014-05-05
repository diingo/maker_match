require 'spec_helper'

describe GladiatorMatch::CreateUser do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:interest_2) { GladiatorMatch.db.create_interest(name: 'java', expertise: 'intermediate')}
  let(:result) { described_class.run(@params) }
  before do
    @params = { first_name: 'Plum', last_name: 'Pits', github_login: 'plum_pits', location: '7748', interests: [interest_1, interest_2]}
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

    # xit 'ensures user is created with valid location' do
    #   VCR.use_cassette('invalid_location') do
    #     # some invalid addresses don't return nil
    #     # ex, 101 Mario Kart World, Austin, Tx just gets coords austin, tx
    #     coords = Geocoder.coordinates('Felony Land')
    #     # binding.pry
    #     expect(coords).to be_nil
    #     # TO DO
    #     # how to stub Geocoder.coordinates to use 'Felony Land'
    #     @params[:location] = 'Felony Land'

    #     expect(result.success?).to eq(false)
    #     expect(result.error).to eq(:invalid_location)
    #   end
    # end

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
    it 'creates a user'
  end
end