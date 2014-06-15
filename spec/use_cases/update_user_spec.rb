require 'spec_helper'

describe GladiatorMatch::UpdateUser do

  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:interest_2) { GladiatorMatch.db.create_interest(name: 'java', expertise: 'intermediate')}

  let(:result) { described_class.run(@params) }

  let(:plum) {
    GladiatorMatch.db.create_user(
      :first_name => 'Plum',
      :last_name => 'Pits',
      :email => 'plum@example.com',
      :github_login => 'plum_pits',
      :github_id => 64,
      :remote => true,
      :interests => [interest_1, interest_2],
      :location => '77478'
    )
  }

  let(:s_key) { GladiatorMatch.db.create_session(user_id: plum.id) }

  before do
    GladiatorMatch.db.clear_everything
    Geocoder.stub(:coordinates).and_return([29.6185208, -95.6090009])
    @params = {
      session_key: s_key
    }
  end

  context 'error handling' do
    it "ensures a user is found with the session key" do
      @params = { session_key: ''}

      result = described_class.run(@params)

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:no_user_with_that_session_key)
    end

    it 'ensures user is updated with valid interests' do
      @params[:interests] = ''
      result = described_class.run(@params)

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_interest)

      @params[:interests] = []
      result = described_class.run(@params)
      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_interest)
    end

    it 'ensures user is updated with valid location' do
      Geocoder.should_receive(:coordinates).with('Felony Land').and_return(nil)
      # some invalid addresses don't return nil
      # ex, 101 Mario Kart World, Austin, Tx just gets coords of austin, tx

      @params[:location] = 'Felony Land'

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_location)
    end

    it 'ensured first and last names are not updated with blank' do
      @params[:first_name] = ''
      result = described_class.run(@params)

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_name)

      @params[:first_name] = 'Plum'
      @params[:last_name] = ''
      result = described_class.run(@params)
      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_name)
    end

    it "ensures remote is updated with boolean" do
      @params[:remote] = 'not boolean'
      result = described_class.run(@params)

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_remote_type)
    end
  end

  context 'success' do
    it 'updates a user' do
      # binding.pry
      expect(result.success?).to eq(true)
      expect(result.user.first_name).to eq('Plum')
      # expect(result.user.github_login).to eq('plum_pits')
      expect(result.user.remote).to eq(true)
      expect(result.user.interests).to be_a(Array)
      expect(result.user.interests.map(&:name)).to include('haskell', 'java')
      expect(result.user.latitude).to eq(29.6185208)
      expect(result.user.longitude).to eq(-95.6090009)
      expect(result.user.location).to eq('77478')

      @params = { first_name: 'Munchkin', last_name: 'Blobwitz', remote: false, interests: [interest_1], location: '77478', email: 'munchy@email.com', session_key: s_key }

      result2 = described_class.run(@params)

      expect(result2.user.remote).to eq(false)
      expect(result2.user.first_name).to eq('Munchkin')
      expect(result2.user.last_name).to eq('Blobwitz')
      expect(result2.user.interests).to be_a(Array)
      expect(result2.user.interests.map(&:name)).to include('haskell')
      expect(result2.user.interests.map(&:name)).to_not include('java')
      expect(result2.user.latitude).to eq(29.6185208)
      expect(result2.user.longitude).to eq(-95.6090009)
      expect(result2.user.location).to eq('77478')
    end
  end
end