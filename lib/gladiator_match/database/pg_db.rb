module GladiatorMatch
  module Database
    class PostGres
      # binding.pry
      def initialize(config = nil)
        ActiveRecord::Base.establish_connection(
          # YAML.load_file("db/config.yml")[env]
          YAML.load_file('db/config.yml')['test']
        )

      end

      def clear_everything
        User.destroy_all
      end

      class User < ActiveRecord::Base
        has_many :groups, :through => :memberships
        has_many :memberships
        has_many :interests
      end

      class Membership < ActiveRecord::Base
        belongs_to :user
        belongs_to :group
      end

      class Group < ActiveRecord::Base
        has_many :users, :through => :memberships
        has_many :memberships
        has_many :invites
      end

      class Session < ActiveRecord::Base
      end

      # should there be some relationship with users
      # even though interest only has two columns for user ids
      class Invite < ActiveRecord::Base
        belongs_to :group
      end

      class Interest < ActiveRecord::Base
      end

      def create_user(attrs)
        ar_user = User.create(attrs)
        GladiatorMatch::User.new(ar_user.attributes)
      end

      def get_user(uid, groups: false)
        ar_user = User.find(uid)
        entity_user = GladiatorMatch::User.new(ar_user.attributes)
        if groups
          entity_user.groups = ar_user.groups
        end
        entity_user
      end

      def all_users
        ar_users = User.all
        ar_users.map { |ar_user| User.new(ar_user.attributes) }
      end

      # def get_user_by_login(github_login)
      #   ar_user = User.where(github_login: github_login).first
      #   entity_user = GladiatorMatch::User.new(ar_user.attributes)
      #   entity_user.groups = ar_user.groups
      # end

      def create_group(attrs)
        # AR Group created with default topic
        if attrs[:topic]
          ar_group = Group.create(topic: attrs[:topic])
        else
          ar_group = Group.create(topic: "Introduce Yourselves")
        end
        attrs[:users].each do |user|
          # .instance_values turns attributes of object into a hash
          # similar to doing .attributes on AR obj
          Membership.create(group_id: ar_group.id, user_id: user.id)
        end

        entity_group = GladiatorMatch::Group.new(ar_group.attributes)
        entity_group.users = attrs[:users]
        entity_group
      end

      def get_group(gid, users: false)
        ar_group = Group.find(gid)
        entity_group = Group.new(ar_group.attributes)
        if users
          entity_group.users = ar_group.users
        end
        entity_group
      end

      def create_invite(attrs)
        ar_invite = Invite.create(attrs)
        entity_invite = GladiatorMatch::Invite.new(ar_invite.attributes)
      end

      def get_invite(iid)
        ar_invite = Invite.find(iid)
        entity_invite = GladiatorMatch::Invite.new(ar_invite.attributes)
      end

      # # # # #  #
      # Interest #
      # # # # #  #

      def create_interest(attrs)
        ar_interest = Interest.create(attrs)
        entity_interest = GladiatorMatch::Interest.new(ar_interest.attributes)
      end

      def get_interest(iid)
        ar_interest = Interest.find(iid)
        entity_interest = GladiatorMatch::Interest.new(ar_interest.attributes)
      end

      # # # # #  #
      # Session ##
      # # # # #  #

      def create_session(attrs)
        # generate unique crazy id for session
        sid = SecureRandom.uuid
        ar_session = Session.create(session_key: sid, user_id: attrs[:user_id])
        sid
      end

      def get_session(skey)
        ar_session = Session.where(session_key: skey).first
        # may need to change :id to :skey for both here and inmemory db
        { id: ar_session.session_key, user_id: ar_session.user_id }
      end
    end
  end
end