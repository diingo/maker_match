module GladiatorMatch
  module Database
    class InMemory

      def initialize(config=nil)
        clear_everything
      end

      def clear_everything
        @user_id_counter = 100
        @group_id_counter = 200
        @users = {}
        @memberships = []
        @groups = {}
        @sessions = {}
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

      def get_user(uid, groups: false)
        user = @users[uid]
        if groups
          user.groups = get_groups_by_user(user.id)
        end
        user
      end

      # # # # #
      # Group #
      # # # # #

      def create_group(attrs)
        id = (@group_id_counter += 1)
        attrs[:id] = id

        group = Group.new(attrs).tap {|group| @groups[id] = group }

        attrs[:users].each do |user|
          @memberships << { group_id: group.id, user_id: user.id}
        end

        group
      end

      def get_group(gid, users: false)
        group = @groups[gid]
        if users
          group.users = get_users_by_group(group.id)
        end
        group
      end

      # # # # # #
      # Session #
      # # # # # #

      def create_session(attrs)
        # generate unique crazy id for session
        sid = SecureRandom.uuid
        @sessions[sid] = { id: sid, user_id: attrs[:user_id] }
        sid
      end

      def get_session(sid)
        # binding.pry
        @sessions[sid]
      end

      # # # # # #
      # Queries #
      # # # # # #

      def get_users_by_group(gid)
        group_hashes = @memberships.select { |memb| memb[:group_id] == gid }
        users = group_hashes.map { |memb| @users[memb[:user_id]]}
      end

      def get_groups_by_user(uid)
        user_hashes = @memberships.select { |memb| memb[:user_id] == uid }
        groups = user_hashes.map { |memb| @groups[memb[:group_id]]}
      end

    end
  end
end