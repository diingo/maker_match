require_relative '../spec_helper.rb'

describe GladiatorMatch::SignIn do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:peach) {
    GladiatorMatch.db.create_user(
      :first_name => 'Peach',
      :last_name => 'Peach',
      :email => 'peach@example.com',
      :github_login => 'peach',
      :interests => [interest_1],
      :password => '123'
    )
  }

  let(:result) { described_class.run(@params) }
  before do
    @params = { email: peach.email , password: peach.password }
  end

  context "failure" do
    it "errors if email does not exist" do
      @params[:email] = "nonperson@email.com"

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:user_nonexistent)
    end

    it "errors if password is incorrect" do
      @params[:password] = "246"

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:incorrect_password)
    end
  end

  context "success" do
    it 'creates a session for a user' do
      expect(result.success?).to eq(true)
      expect(result.session_key).to be_a(String)
      expect(result.session_key.length > 15).to be(true)
    end
  end

end