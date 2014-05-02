module GladiatorMatch
  class CreateInvite < UseCase

    def run(inputs)
      session_key = inputs[:inviter_session_key]
      invitee_github_login = inputs[:invitee_github_login]

      invitee = GladiatorMatch.db.get_user_by_login(invitee_github_login)
      return failure(:missing_invitee) if invitee.nil?

      # get user from session, create invite and return success
      inviter = GladiatorMatch.db.get_user_by_session(session_key)
      invite = GladiatorMatch.db.create_invite(inviter_id: inviter.id, invitee_id: invitee.id)

      success(invite: invite, invitee: invitee, inviter: inviter)
    end

  end
end