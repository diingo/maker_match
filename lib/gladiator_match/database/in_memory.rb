module GladiatorMatch
  module Database
    class InMemory

      def initialize(config=nil)
        clear_everything
      end

      def clear_everything
        @user_id_counter = 100
        @users = {}
      end

      # # # # #
      # Users #
      # # # # #
      
      def all_users
        @users.values
      end

      def create_user(attrs)
        id = (@user_id_counter += 1)
        attrs[:id] = id

        User.new(attrs).tap {|user| @users[id] = user }
      end

      def get_user(uid)
        @users[uid]
      end

    end
  end
end