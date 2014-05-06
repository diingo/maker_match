module GladiatorMatch
  module Database
    class InMemory

      def initialize(config=nil)
        clear_everything
      end

      def clear_everything
        @user_id_counter = 100
        @group_id_counter = 200
        @invite_id_counter = 300
        @interest_id_counter = 400
        @users = {}
        @memberships = []
        @groups = {}
        @sessions = {}
        @invites = {}
        @interests = {}
      end

      # # # # #
      # Users #
      # # # # #

      def all_users
        @users.values.map do |attrs|
          User.new(attrs)
        end
      end

      def create_user(attrs)
        attrs[:id] = (@user_id_counter += 1)

        User.new(attrs).tap {|user| @users[user.id] = attrs }
      end

      def get_user(uid, groups: false)
        attrs = @users[uid]
        user = User.new(attrs)
        if groups
          user.groups = get_groups_by_user(user.id)
        end
        user
      end

      # def all_users
      #   @users.values
      # end

      # def create_user(attrs)
      #   id = (@user_id_counter += 1)
      #   attrs[:id] = id

      #   User.new(attrs).tap {|user| @users[id] = user }
      # end

      # def get_user(uid, groups: false)
      #   user = @users[uid]
      #   if groups
      #     user.groups = get_groups_by_user(user.id)
      #   end
      #   user
      # end

      # def get_user_by_login(github_login)
      #   @users.values.find { |user| user.github_login == github_login }
      # end

      def get_user_by_login(github_login)
        all_users.find { |user| user.github_login == github_login }
      end

      def get_user_by_session(sid)
        user_id = @sessions[sid][:user_id]
        user = get_user(user_id, groups: true)
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
      # Invite  #
      # # # # # #

      def create_invite(attrs)
        id = (@invite_id_counter += 1)
        attrs[:id] = id
        invite = Invite.new(attrs)

        @invites[id] = invite

        invite
      end

      def get_invite(iid)
        @invites[iid]
      end

      # # # # #  #
      # Interest #
      # # # # #  #

      def create_interest(attrs)
        id = (@interest_id_counter += 1)
        attrs[:id] = id

        Interest.new(attrs).tap {|interest| @interests[id] = interest }
      end

      def get_interest(iid)
        @interests[iid]
      end

      # # # # # #
      # Queries #
      # # # # # #

      # def get_users_by_group(gid)
      #   group_hashes = @memberships.select { |memb| memb[:group_id] == gid }
      #   users = group_hashes.map { |memb| @users[memb[:user_id]]}
      # end

      def get_users_by_group(gid)
        group_hashes = @memberships.select { |memb| memb[:group_id] == gid }
        users_attrs = group_hashes.map { |memb| @users[memb[:user_id]]}
        users_attrs.map { |attrs| User.new(attrs) }
      end

      def get_groups_by_user(uid)
        user_hashes = @memberships.select { |memb| memb[:user_id] == uid }
        groups = user_hashes.map { |memb| @groups[memb[:group_id]]}
      end

    end
  end
end