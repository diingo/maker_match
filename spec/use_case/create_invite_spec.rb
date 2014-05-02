require 'spec_helper'

describe GladiatorMatch::CreateInvite do
  let(:luigi) {
    GladiatorMatch.db.create_user(
      :first_name => 'Luigi',
      :last_name => 'Mario',
      :email => 'luigi@example.com',
      :github_login => 'luigi_mario'
    )
  }

  let(:peach) {
    GladiatorMatch.db.create_user(
      :first_name => 'Peach',
      :last_name => 'Peach',
      :email => 'peach@example.com',
      :github_login => 'peach'
    )
  }

  let(:session_key) { GladiatorMatch.db.create_session(user_id: luigi.id) }

  let(:result) { described_class.run(@params) }

  before do
    @db = GladiatorMatch.db
    @params = { inviter_session_key: session_key, invitee_github_login: peach.github_login }
  end

  context "failure" do
    it "ensures the invitee exists" do
      @params[:invitee_github_login] = "apple_bomb"
      expect(result.success?).to eq(false)
      expect(result.error).to eq(:missing_invitee)
    end
  end

  context "success" do
    it "creates an invite" do
      expect(result.success?).to eq(true)

      expect(result.invite.inviter_id).to eq(luigi.id)
      expect(result.invite.invitee_id).to eq(peach.id)
      expect(result.inviter.first_name).to eq('Luigi')
      expect(result.invitee.first_name).to eq('Peach')
    end
  end


end