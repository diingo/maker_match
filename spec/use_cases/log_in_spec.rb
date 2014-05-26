require_relative '../spec_helper.rb'

describe GladiatorMatch::LogIn do

  let(:mario) {
    GladiatorMatch.db.create_user(
      :first_name => 'Mario',
      :last_name => 'Mario',
      :email => 'mario@example.com',
      :github_login => 'mario_mario'
    )
  }

  let(:result) { described_class.run(@params) }

  before do
    @params = { }
  end

  context "failure" do
    it "errors if login is invalid - empty string or nil" do
      @params[:github_login] = ''

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_login)
    end

  end

  context "success" do
    it 'creates a session' do
      @params[:github_login] = 'peach'
      expect(result.success?).to eq(true)
      expect(result.session_key).to be_a(String)
      expect(result.session_key.length > 20). to eq(true)
    end

    context "new user" do
      it 'creates a user and adds user id to the session' do
        # a user with this github_login does not exist
        @params[:github_login] = 'peach'

        expect(result.user.github_login).to eq('peach')
        expect(result.user.first_name).to be_nil

        session_user_id = GladiatorMatch.db.get_session(result.session_key)[:user_id]
        expect(result.user.id).to eq(session_user_id)
      end
    end

    context "existing user" do
      it 'creates a session and adds existing user id to the session' do
        # a user with this github_login exists
        @params[:github_login] = mario.github_login
        expect(result.success?).to eq(true)
        expect(result.user.github_login).to eq('mario_mario')
        expect(result.user.first_name).to eq('Mario')

        session_user_id = GladiatorMatch.db.get_session(result.session_key)[:user_id]
        expect(result.user.id).to eq(session_user_id)
      end
    end
  end

end