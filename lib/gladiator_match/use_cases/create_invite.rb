module GladiatorMatch
  class CreateInvite < UseCase

    def run(inputs)
      invitee = GladiatorMatch.db.get_user(inputs[:invitee].id, groups: false)

      return failure(:invalid_user) if invitee.nil?

    end

  end
end