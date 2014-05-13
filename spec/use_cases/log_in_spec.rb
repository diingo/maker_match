require_relative '../spec_helper.rb'

describe GladiatorMatch::LogIn do
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
    @params = { github_login: peach.github_login }
  end

  context "failure" do
    it "errors if login is invalid - empty string or nil" do
      @params[:github_login] = ''

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_login)
    end

  end

  context "success" do
    it 'creates a session - no user id yet (that will be added to the session later after we run create user use case)' do
      expect(result.success?).to eq(true)
      expect(result.session_key).to be_a(String)
      expect(result.session_key.length > 20). to eq(true)
    end
  end

end