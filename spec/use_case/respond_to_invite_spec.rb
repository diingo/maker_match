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

  let(:invite) { GladiatorMatch.db.create_invite(inviter_id: luigi.id, invitee_id: peach.id)}

  let(:result) { described_class.run(@params) }

  before do
    @params = { invite_id: invite.id, response: "accept" }
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
end