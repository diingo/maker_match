module GladiatorMatch
  class Group < Entity
    attr_accessor :id, :users, :topic

    def initialize(attrs)
      @topic = "Introduce Yourselves"
      super(attrs)
    end
  end
end
