module GladiatorMatch
  class Interest < Entity
    # subtopic would be an area in a language, such as Rails and TDD for ruby
    attr_accessor :language, :subtopic, :expertise
  end
end