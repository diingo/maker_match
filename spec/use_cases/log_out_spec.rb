require 'spec_helper'

describe GladiatorMatch::LogOut do
  let(:mario) {
    GladiatorMatch.db.create_user(
      :first_name => 'Mario',
      :last_name => 'Mario',
      :email => 'mario@example.com',
      :github_login => 'mario_mario',
      :github_id => 64
    )
  }

  let(:session_key) { GladiatorMatch.db.create_session(user_id: mario.id) }

  let(:result) { described_class.run(@params)}

  before do
    GladiatorMatch.db.clear_everything
    @params = {
      session_key: session_key
    }
  end

  context 'failure' do
    it "errors if a user is not logged in" do
      @params = {}
      expect(result.success?).to eq(false)
      expect(result.error).to eq(:no_one_logged_in_to_log_out)
    end
  end

  context 'success' do
    it "logs the user out - destroys the session" do
      session = GladiatorMatch.db.get_session(session_key)
      expect(session).to_not be_nil

      expect(result.success?).to eq(true)
      session_2 = GladiatorMatch.db.get_session(session_key)
      expect(session_2).to be_nil
    end
  end
end