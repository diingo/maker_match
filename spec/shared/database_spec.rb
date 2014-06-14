shared_examples 'a database' do

  let(:db) { described_class.new }
  let(:interest_1) { db.create_interest(name: 'haskell', expertise: 'beginner') }
  let(:interest_2) { db.create_interest(name: 'java', expertise: 'beginner') }

  let(:toad) {
    db.create_user(
      :first_name => 'Toad',
      :last_name => 'Toad',
      :email => 'toad@example.com',
      :github_login => 'toad',
      :interests => [],
      :github_id => 112
    )
  }

  let(:mario) {
    db.create_user(
      :first_name => 'Mario',
      :last_name => 'Mario',
      :email => 'mario@example.com',
      :github_login => 'mario_mario',
      :interests => [interest_1, interest_2],
      :github_id => 113
    )
  }

  let(:luigi) {
    db.create_user(
      :first_name => 'Luigi',
      :last_name => 'Mario',
      :email => 'luigi@example.com',
      :github_login => 'luigi_mario',
      :interests => [interest_2],
      :github_id => 114
    )
  }

  let(:peach) {
    db.create_user(
      :first_name => 'Peach',
      :last_name => 'Peach',
      :email => 'peach@example.com',
      :github_login => 'peach',
      :interests => [interest_1],
      :github_id => 115
    )
  }

  before do
    Geocoder.stub(:coordinates).and_return([29.6185208, -95.6090009])
    db.clear_everything
  end

  describe 'Users' do
    it "creates a user" do
      user = db.create_user(:first_name => 'Mario', :last_name => 'Mario', :email => 'mario@example.com', :github_login => 'mario_mario')
      expect(user).to be_a GladiatorMatch::User
      expect(user.first_name).to eq 'Mario'
      expect(user.id).to_not be_nil
    end

    it "gets a user" do
      user = db.create_user(:first_name => 'Luigi', :last_name => 'Mario', :email => 'luigi@example.com', :github_login => 'luigi_mario', :github_id => 113, :interests => [interest_1, interest_2], :location => 77478)

      retrieved_user = db.get_user(user.id)

      expect(retrieved_user.github_login).to eq 'luigi_mario'
      expect(retrieved_user.last_name).to eq 'Mario'
      expect(retrieved_user.first_name).to eq 'Luigi'
      expect(retrieved_user.email).to eq 'luigi@example.com'
      expect(retrieved_user.github_id).to eq(113)
      expect(retrieved_user.interests.map &:name).to include('haskell', 'java')
      expect(retrieved_user.latitude).to eq(29.6185208)
      expect(retrieved_user.longitude).to eq(-95.6090009)
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

    it "gets a user by github id" do
      retrieved_user = db.get_user_by_github_id(toad.github_id)

      expect(retrieved_user.first_name).to eq('Toad')
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

    it "updates a user" do
      retrieved_user = db.get_user(luigi.id)
      expect(retrieved_user.github_login).to eq('luigi_mario')

      # update the user's github login
      retrieved_user.github_login = 'super_luigi'
      db.update_user(retrieved_user)

      updated_user = db.get_user(retrieved_user.id)
      expect(updated_user.github_login).to eq('super_luigi')
    end

    it "gets all users by interest"
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

    it "updates a group's basic attributes" do
      group = db.create_group(users: [mario, luigi], topic: 'haskell')

      group.topic = 'plumbing'
      db.update_group(group)
      retrieved_group = db.get_group(group.id)

      retrieved_group = db.get_group(retrieved_group.id, users: true)
      expect(retrieved_group.users.map(&:first_name)).to include('Mario', 'Luigi')
      expect(retrieved_group.topic).to eq('plumbing')
    end

    it "updates a group's users" do
      group = db.create_group(users: [mario, luigi], topic: 'powerups')
      group.users << peach
      db.update_group(group)

      retrieved_group = db.get_group(group.id, users: true)
      expect(retrieved_group.users.map(&:first_name)).to include('Mario', 'Luigi', 'Peach')
      expect(retrieved_group.topic).to eq('powerups')
    end
  end

  describe 'Sessions', pending: true do

    it "creates and gets a session" do
      session_id = db.create_session(user_id: mario.id)
      retrieved_session = db.get_session(session_id)
      expect(retrieved_session[:user_id]).to eq(mario.id)
    end

    it "can create session with no user id" do
      session_id = db.create_session
      retrieved_session = db.get_session(session_id)
      expect(retrieved_session[:user_id]).to be_nil
    end

    it "can update a session" do
      session_id = db.create_session
      updated_session = db.get_session(session_id)
      updated_session[:user_id] = peach.id
      db.update_session(updated_session)

      retrieved_session = db.get_session(session_id)
      expect(retrieved_session[:user_id]).to eq(peach.id)
    end
  end

  describe 'Invites', pending: true do
    it "creates and gets invites" do
      invite = db.create_invite(inviter_id: mario.id, invitee_id: peach.id)
      retrieved_invite = db.get_invite(invite.id)

      expect(retrieved_invite.invitee_id).to eq(peach.id)
      expect(retrieved_invite.inviter_id).to eq(mario.id)
    end

    it "updates invites" do
      invite = db.create_invite(inviter_id: mario.id, invitee_id: peach.id)
      expect(invite.pending?).to eq(true)

      invite.response = "accept"
      db.update_invite(invite)
      updated_invite = db.get_invite(invite.id)
      expect(updated_invite.pending?).to eq(false)
    end
  end

  describe 'Interests', pending: true do

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

  describe 'Queries', pending: true do

    before do
      @group_1 = db.create_group(users: [toad, mario, luigi], topic: 'haskell')
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

    it "gets all users with a specified interest" do
      # ensure our let statements create these users
      users = db.get_users_by_interest(name: interest_1.name, expertise: interest_1.expertise)
      expect(users.map(&:first_name)).to include('Mario', 'Peach')
      expect(users.map(&:first_name)).to_not include('Luigi')

    end
  end
end