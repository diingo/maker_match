module GladiatorMatch
  class CreateInvite < UseCase

    #TO DO deal with group id issue here - reference RespondToInvite usecase and bring it's group id stuff here
    def run(inputs)
      session_key = inputs[:inviter_session_key]
      invitee_github_login = inputs[:invitee_github_login]

      # nil.to_i doesn't throw an error - it converts nil to 0
      # but we don't want nil to become 0
      # so we use &&=
      # since && requires both sides to be true
      # it doesn't evaluate the value on the right hand side if the left
      # side is false (like nil) - this prevents our nil from becoming 0
      # but still allows string integers (which are truthy)
      # to get converted to real integers.
      #
      inputs[:group_id] &&= inputs[:group_id].to_i

      invitee = GladiatorMatch.db.get_user_by_login(invitee_github_login)
      return failure(:missing_invitee) if invitee.nil?

      # get user from session, create invite and return success
      inviter = GladiatorMatch.db.get_user_by_session(session_key)

      invite = GladiatorMatch.db.create_invite(inviter_id: inviter.id, invitee_id: invitee.id)

      # it's ok to have a nil group id but if group id is not nil,
      # we try to find that group in the db and assign it to the invite
      unless inputs[:group_id].nil?
        group = GladiatorMatch.db.get_group(inputs[:group_id])
        return failure(:no_group_with_that_id) if group.nil?
        invite.group_id = group.id
      end

      success(invite: invite, invitee: invitee, inviter: inviter)
    end

  end
end


# this is what we could have done if we used Solid Use Case Gem:

# assign_group_to_invite(invite, inputs)

# def assign_group_to_invite(invite, inputs)
#   group = GladiatorMatch.db.get_group(inputs[:group_id])
#   return failure(:no_group_with_that_id) if group.nil?

#   invite.group_id = group.id
# end