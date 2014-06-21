module GladiatorMatch
  class LogOut < UseCase
    def run(inputs)

      return failure(:no_one_logged_in_to_log_out) unless inputs[:session_key]

      GladiatorMatch.db.destroy_session(inputs[:session_key])

      return success
    end
  end
end