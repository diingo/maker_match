module GladiatorMatch
  class SignUp < UseCase
    def run(inputs)
      user = GladiatorMatch.db.get_user_by_email(inputs[:email])

      return failure(:email_already_in_use) if user.nil? == false
      
    end
  end
end