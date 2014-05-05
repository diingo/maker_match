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

  let(:group) { GladiatorMatch.db.create_group(users: [luigi, peach], topic: "haskell") }

  let(:session_key) { GladiatorMatch.db.create_session(user_id: luigi.id) }

  let(:result) { described_class.run(@params) }

  before do
    @db = GladiatorMatch.db
    @params = { inviter_session_key: session_key, invitee_github_login: peach.github_login, group_id: group.id }
  end

  context "failure" do
    it "ensures the invitee exists" do
      @params[:invitee_github_login] = "apple_bomb"

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:missing_invitee)
    end

    it "ensures the group exists if id is not nil" do
      @params[:group_id] = 9999

      expect(result.success?).to eq(false)
      expect(result.error). to eq(:no_group_with_that_id)
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

    it "converts string ids to integers" do
      @params[:group_id] = group.id.to_s

      expect(result.success?).to eq(true)

      expect(result.invite.group_id).to eq(group.id)
    end

    it "allows both nil and existing group id" do
      @params[:group_id] = nil

      # TO DO
      # why do I have to set result here for it to not be nil?
      # it seems this test is doing something in the background that causes
      # expect(result.invite.group_id).to be_nil to pass for the wrong reason if
      # I don't set `result = described_class.run(@params)`
      result = described_class.run(@params)
      expect(result.invite.group_id).to be_nil

      @params[:group_id] = group.id
      result = described_class.run(@params)
      expect(result.invite.group_id).to_not be_nil
      expect(result.invite.group_id).to eq(group.id)
    end
  end


end