module GladiatorMatch
  class CreateInterest < UseCase
    def run(inputs)
      
      return failure(:invalid_expertise) unless inputs[:expertise].match /^beginner|intermediate|advanced$/

      return failure(:invalid_name) unless valid_name?(inputs[:name])

      interest = GladiatorMatch.db.create_interest(expertise: inputs[:expertise], name: inputs[:name])
      success(interest: interest)
    end

    def valid_name?(name)
      name.nil? == false && name.empty? == false
    end
  end
end