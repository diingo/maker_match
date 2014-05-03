module GladiatorMatch
  class Invite < Entity
    attr_accessor :inviter_id, :invitee_id, :id, :response

    def initialize(attrs)
      super(attrs)
    end

    def pending?
      if @response != nil
        false
      else
        true
      end
    end
  end
end