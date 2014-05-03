module GladiatorMatch
  class RespondToInvite < UseCase
    def run(inputs)
      inputs[:invite_id] = inputs[:invite_id].to_i
      invite_id = inputs[:invite_id]

      invite = GladiatorMatch.db.get_invite(invite_id)
      return failure(:invalid_invite) if invite.nil?

      return failure(:invalid_response) unless inputs[:response].match /^accept|ignore$/

      return failure(:invalid_invite_type) unless inputs[:invite_type].match /^create_pair|join_group$/

      if inputs[:response] == "accept"
        invite.response = "accept"
      elsif inputs[:response] == "ignore"
        invite.response = "ignore"
      end

      success(invite: invite)
    end
  end
end