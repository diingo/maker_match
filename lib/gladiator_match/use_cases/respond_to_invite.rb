module GladiatorMatch
  class RespondToInvite < UseCase
    def run(inputs)
      inputs[:invite_id] = inputs[:invite_id].to_i
      invite_id = inputs[:invite_id]

      invite = GladiatorMatch.db.get_invite(invite_id)
      return failure(:invalid_invite) if invite.nil?
      return failure(:invalid_response) unless inputs[:response].match /^accept|ignore$/

      invite.response = "accept" if inputs[:response] == "accept"
      invite.response = "ignore" if inputs[:response] == "ignore"

      inviter = GladiatorMatch.db.get_user(invite.inviter_id)
      invitee = GladiatorMatch.db.get_user(invite.invitee_id)

      if invite.group_id.nil?
        group = GladiatorMatch.db.create_group(users: [inviter, invitee])
      else
        # is this the correct approach?
        group = GladiatorMatch.db.get_group(invite.group_id)
        group.users << invitee
      end

      success(invite: invite, group: group)
    end
  end
end