module GladiatorMatch
  class CreateGroup < UseCase

    def run(inputs)
      users = inputs[:users]

      return failure(:invalid_users) unless validate_users?(users)

    end

    def validate_users?(users)

    end

    # def run(params)
    #   attempt_all do
    #     step { validate(params) }
    #   end
    # end

    # def validate(params)
    #   users = params[:users]
    #   users.each do |user|
    #     # GladiatorMatch.db.get_user(user.id, groups: false)
    #     if user.valid?
    #       params[:user] = user
    #       Success(params)
    #     else
    #       fail :invalid_user, :user => user
    #     end
    #   end
    # end
  end
end