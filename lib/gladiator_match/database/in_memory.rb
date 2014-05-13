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

      def get_user_by_email(email)
        user_attrs = @users.values.find { |attrs| attrs[:email] == email }
        return nil if user_attrs.nil?
        User.new(user_attrs)
      end

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

        group = Group.new(attrs).tap {|group| @groups[id] = attrs }

        attrs[:users].each do |user|
          @memberships << { group_id: group.id, user_id: user.id}
        end

        group
      end

      def get_group(gid, users: false)
        group_attrs = @groups[gid]
        return nil if group_attrs.nil?

        group = Group.new(group_attrs)
        if users
          group.users = get_users_by_group(group.id)
        end
        group
      end

      def update_group(group)
        retrieved_attrs = @groups[group.id]
        # get the instance attributes as a hash and convert the keys from strings to symbols
        # TO DO
        updated_attrs = Hash[group.instance_values.map do |k,v|
          [k.to_sym,v]
        end]
        # binding.pry
        updated_attrs.each do |attr_type, new_value|
          retrieved_attrs[attr_type] = new_value
        end

        updated_attrs[:users].each do |user|
          hash = { group_id: group.id, user_id: user.id}

          @memberships << { group_id: group.id, user_id: user.id} unless @memberships.include?(hash)
        end

        Group.new(updated_attrs)
      end

      # # # # # #
      # Session #
      # # # # # #

      def create_session(attrs = {})
        # generate unique crazy id for session
        sid = SecureRandom.uuid
        attrs[:user_id] = nil if attrs[:user_id].nil?
        @sessions[sid] = { id: sid, user_id: attrs[:user_id] }
        sid
      end

      def get_session(sid)

        @sessions[sid]
      end

      # # # # # #
      # Invite  #
      # # # # # #

      def create_invite(attrs)
        attrs[:id] = (@invite_id_counter += 1)
        Invite.new(attrs).tap { |invite| @invites[attrs[:id]] = attrs }
      end

      def get_invite(iid)
        invite_attrs = @invites[iid]
        return nil if invite_attrs.nil?

        Invite.new(invite_attrs)
      end

      # TO DO
      def update_invite(updated_invite)
        retrieved_invite = @invites[updated_invite.id]
        updated_invite_attrs = updated_invite.instance_values
        updated_invite_attrs.each do |attr_type, new_value|
          # retrieved_invite.send(:attr_type = new_value)
        end
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
        group_attrs = user_hashes.map { |memb| @groups[memb[:group_id]]}
        group_attrs.map { |attrs| Group.new(attrs) }
      end

      def get_users_by_interest(attrs)

        selected_user_attrs = []
        selected_users = []
        @users.values.each do |user_attrs|
          desired_interest = user_attrs[:interests].select do |interest|
            interest.name == attrs[:name] && interest.expertise == attrs[:expertise]
          end

          # if user has the desired interests matched, add to selected_users array
          selected_user_attrs << user_attrs unless desired_interest.empty?
          selected_users = selected_user_attrs.map do |user_attr|
            User.new(user_attr)
          end
        end

        selected_users
      end


      # def get_users_by_interest(attrs)

      #   selected_users = []

      #   @users.values.each do |user_attrs|
      #     desired_interest = user_attrs[:interests].select do |interest|
      #       interest.name == attrs[:name] && interest.expertise == attrs[:expertise]
      #     end

      #     # if user has the desired interests matched, add user_attrs to selected_users array
      #     # then map the user objects
      #     binding.pry
      #     selected_users << user_attrs unless desired_interest.empty?
      #     selected_users = selected_users.map do |user_attr|
      #       User.new(user_attr)
      #     end
      #   end

      #   selected_users
      # end

    end
  end
end