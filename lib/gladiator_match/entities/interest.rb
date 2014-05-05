module GladiatorMatch
  class Interest < Entity
    # topic would be an area in a language, such as Rails and TDD for ruby
    attr_accessor :name, :expertise
  end
end