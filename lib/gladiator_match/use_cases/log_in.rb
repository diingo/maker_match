module GladiatorMatch
  class LogIn < UseCase
    def run(inputs)
      return failure(:invalid_login) if inputs[:github_login].blank?

      if GladiatorMatch.db.get_user_by_github_id(inputs[:github_id]).nil?
        user = GladiatorMatch.db.create_user(github_login: inputs[:github_login], github_id: inputs[:github_id])
      else
        user = GladiatorMatch.db.get_user_by_github_id(inputs[:github_id])

        # Update user's github login if it has changed
        if user.github_login != inputs[:github_login]
          user.github_login = inputs[:github_login]
          user = GladiatorMatch.db.update_user(user)
        end
      end

      session_key = GladiatorMatch.db.create_session(user_id: user.id)

      success(session_key: session_key, user: user)
    end
  end
end