shared_examples 'a database' do
  let(:db) { described_class.new }

  let(:mario) {
    db.create_user(
      :first_name => 'Mario',
      :last_name => 'Mario',
      :email => 'mario@example.com',
      :github_login => 'mario_mario'
    )
  }

  let(:luigi) {
    db.create_user(
      :first_name => 'Luigi',
      :last_name => 'Mario',
      :email => 'luigi@example.com',
      :github_login => 'luigi_mario'
    )
  }

  let(:peach) {
    db.create_user(
      :first_name => 'Peach',
      :last_name => 'Peach',
      :email => 'peach@example.com',
      :github_login => 'peach'
    )
  }

  before { db.clear_everything }

  describe 'Users' do
    it "creates a user" do
      user = db.create_user(:first_name => 'Mario', :last_name => 'Mario', :email => 'mario@example.com', :github_login => 'mario_mario')
      expect(user).to be_a GladiatorMatch::User
      expect(user.first_name).to eq 'Mario'
      expect(user.id).to_not be_nil
    end

    it "gets a user" do
      user = db.create_user(:first_name => 'Luigi', :last_name => 'Mario', :email => 'luigi@example.com', :github_login => 'luigi_mario')
      retrieved_user = db.get_user(user.id)

      expect(retrieved_user.github_login).to eq 'luigi_mario'
      expect(retrieved_user.last_name).to eq 'Mario'
      expect(retrieved_user.first_name).to eq 'Luigi'
      expect(retrieved_user.email).to eq 'luigi@example.com'
    end

    it "gets all users" do
      %w{Peach Harley}.each {|name| db.create_user :first_name => name }

      expect(db.all_users.count).to eq 2
      expect(db.all_users.map &:first_name).to include('Peach', 'Harley')
    end

    it "gets a user by github_login" do
      retrieved_user = db.get_user_by_login(peach.github_login)

      expect(retrieved_user.first_name).to eq('Peach')
    end

    it "gets a user by session key/id" do
      sid = db.create_session(user_id: peach.id)
      retrieved_user = db.get_user_by_session(sid)
      expect(retrieved_user.first_name).to eq('Peach')
    end

    it "gets a user by email" do
      retrieved_user = db.get_user_by_email(luigi.email)
      expect(retrieved_user.first_name).to eq('Luigi')
    end
  end


  describe 'Groups' do

    it "creates a group with default topic" do
      group = db.create_group(users: [mario, luigi])
      expect(group).to be_a GladiatorMatch::Group
      expect(group.users.map &:first_name).to include 'Mario', 'Luigi'
      expect(group.id).to_not be_nil
      expect(group.topic).to eq('Introduce Yourselves')
    end

    it "gets a group" do
      group = db.create_group(users: [mario, luigi], topic: 'haskell')
      retrieved_group = db.get_group(group.id, users: true)

      expect(retrieved_group.topic).to eq('haskell')
      expect(retrieved_group.users.map &:first_name).to include 'Mario', 'Luigi'
    end
  end

  describe 'Sessions' do

    it "creates and gets a session" do
      session_id = db.create_session(user_id: mario.id)
      retrieved_session = db.get_session(session_id)
      expect(retrieved_session[:user_id]).to eq(mario.id)
    end
  end

  describe 'Invites' do
    it "creates and gets invites" do
      invite = db.create_invite(inviter_id: mario.id, invitee_id: peach.id)
      retrieved_invite = db.get_invite(invite.id)

      expect(retrieved_invite.invitee_id).to eq(peach.id)
      expect(retrieved_invite.inviter_id).to eq(mario.id)
    end
  end

  describe 'Interests' do

    it 'creates an interest' do
      interest = db.create_interest(name: 'haskell', expertise: 'beginner')

      expect(interest.name).to eq('haskell')
      expect(interest.expertise).to eq('beginner')
    end

    it 'gets an interest' do
      interest = db.create_interest(name: 'java', expertise: 'beginner')
      retrieved_interest = db.get_interest(interest.id)

      expect(retrieved_interest.name).to eq('java')
    end
  end

  describe 'Queries' do

    before do
      @group_1 = db.create_group(users: [mario, luigi], topic: 'haskell')
      @group_2 = db.create_group(users: [mario, peach], topic: 'html')
    end

    it "gets all groups for a user" do
      mario_groups = db.get_user(mario.id, groups: true).groups
      expect(mario_groups.count).to eq(2)
      expect(mario_groups.map(&:topic)).to include('haskell', 'html')

      mario_groups_v2 = db.get_groups_by_user(mario.id)
      expect(mario_groups_v2.count).to eq(2)
      expect(mario_groups_v2.map &:topic).to include('haskell','html')
    end

    it "gets all users for a group" do
      group_1_users = db.get_group(@group_1.id, users: true).users
      group_1_users_names = group_1_users.map(&:first_name)
      expect(group_1_users_names).to include('Mario', 'Luigi')
      expect(group_1_users_names).to_not include('Peach')

      group_1_users_v2 = db.get_users_by_group(@group_1.id)
      group_1_users_names_v2 = group_1_users_v2.map(&:first_name)
      expect(group_1_users_names).to include('Mario', 'Luigi')
      expect(group_1_users_names).to_not include('Peach')
    end

  end
end