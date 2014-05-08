require_relative '../spec_helper.rb'

describe GladiatorMatch::SignUp do

  let(:result) { described_class.run(@params) }
  before do
    @params = {
      email: 'plum_pits@email.com',
      password: '123'
    }
  end

  context "failure" do
    it "ensures email is not already used" do
      user = GladiatorMatch.db.create_user(email: 'plum_pits@email.com', password: '123')

      expect(result.success?).to eq(false)
      # will want to ask if they forgot their password
      expect(result.error).to eq(:email_already_in_use)
    end
  end

  xit "creates a new user when they sign up" do
    expect(result.success?).to eq(true)
    expect(result.player.email).to eq('plum_pits@email.com')
  end

end