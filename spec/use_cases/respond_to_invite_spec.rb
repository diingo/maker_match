require 'spec_helper'

describe GladiatorMatch::RespondToInvite do
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

  let(:mario) {
    GladiatorMatch.db.create_user(
      :first_name => 'Mario',
      :last_name => 'Mario',
      :email => 'mario@example.com',
      :github_login => 'mario_mario'
    )
  }

  let(:invite) { GladiatorMatch.db.create_invite(inviter_id: luigi.id, invitee_id: peach.id, group_id: nil)}

  let(:result) { described_class.run(@params) }

  before do
    @params = { invite_id: invite.id, response: 'accept' }
  end

  context 'failure' do
    it 'ensures the invite exists' do
      @params[:invite_id] = 9999

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_invite)
    end
  end

  it "changes invite pending status to false when invitee responds" do
    # use case not yet run so pending? should be true
    expect(invite.pending?).to eq(true)

    # now we run the use case by calling the variable 'result'
    # thus, pending? should now be false
    expect(result.success?).to eq(true)
    expect(invite.pending?).to eq(false)
    expect(result.invite.id).to eq(invite.id)
  end

  it "changes invite response to 'accept' if accepted" do
    expect(invite.response).to eq(nil)

    @params[:response] = 'accept'
    expect(result.success?).to eq(true)
    expect(result.invite.pending?).to eq(false)
    expect(result.invite.response).to eq('accept')
  end

  it "changes invite response to 'ignore' if ignored" do
    @params[:response] = 'ignore'
    expect(result.success?).to eq(true)
    expect(result.invite.pending?).to eq(false)
    expect(result.invite.response).to eq('ignore')
  end

  it "converts string ids to integers" do
    @params[:invite_id] = invite.id.to_s

    expect(result.success?).to eq(true)
  end

  it "creates a group between inviter and invitee if invite has nil group_id" do
    expect(invite.group_id).to be_nil

    expect(result.success?).to eq(true)

    expect(result.group.users.map(&:first_name)).to include('Luigi', 'Peach')
    expect(result.group.users.map(&:first_name)).to_not include('Mario')
  end

  it "adds invitee to group if invite's group id is not nil" do
    group = GladiatorMatch.db.create_group(users: [luigi, peach], topic: "haskell")
    # create an invite to a group that already has peach and luigi
    invite = GladiatorMatch.db.create_invite(inviter_id: luigi.id, invitee_id: mario.id, group_id: group.id )
    @params[:invite_id] = invite.id

    expect(result.success?).to eq(true)
    expect(result.group.users.map(&:first_name)).to include('Luigi', 'Peach', 'Mario')
  end
end