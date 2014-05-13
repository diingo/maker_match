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
      updated_invite = GladiatorMatch.db.update_invite(invite)

      inviter = GladiatorMatch.db.get_user(invite.inviter_id)
      invitee = GladiatorMatch.db.get_user(invite.invitee_id)

      if invite.group_id.nil?
        group = GladiatorMatch.db.create_group(users: [inviter, invitee])
      else
        # is this the correct approach? .. it's not!!
        # TO DO: change group.users << invitee to use a db method instead
        group = GladiatorMatch.db.get_group(invite.group_id)

        # TO DO: complete this
        # such that the membership join table is updated as well
        group.users << invitee
        db.update_group(group)

        updated_group = GladiatorMatch.db.get_group(group.id)
      end

      success(invite: updated_invite, group: updated_group)
    end
  end
end