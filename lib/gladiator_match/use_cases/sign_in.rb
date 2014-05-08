module GladiatorMatch
  class SignIn < UseCase
    def run(inputs)

      user = GladiatorMatch.db.get_user_by_email(inputs[:email])
      return failure(:user_nonexistent) if user.nil?

      return failure(:incorrect_password) if inputs[:password] != user.password

      
      session_key = GladiatorMatch.db.create_session(user_id: user.id)
      success({ session_key: session_key })
    end
  end
end