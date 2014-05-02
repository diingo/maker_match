require 'spec_helper'

describe GladiatorMatch::Database::InMemory do
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
  end


  describe 'Groups' do

    it "creates a group" do
      group = db.create_group(users: [mario, luigi], topic: 'haskell')
      expect(group).to be_a GladiatorMatch::Group
      expect(group.users.map &:first_name).to include 'Mario', 'Luigi'
      expect(group.id).to_not be_nil
      expect(group.topic).to eq('haskell')
    end

    it "gets a group" do
      group = db.create_group(users: [mario, luigi], topic: 'haskell')
      retrieved_group = db.get_group(group.id)

      expect(retrieved_group.topic).to eq('haskell')
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

  describe 'Queries' do

    before do
      @group_1 = db.create_group(users: [mario, luigi], topic: 'haskell')
      @group_2 = db.create_group(users: [mario, peach], topic: 'html')
    end

    it "gets all groups for a user" do
      mario_groups = db.get_user(mario.id, groups: true).groups
      expect(mario_groups.count).to eq(2)

      group_topics = mario_groups.map(&:topic)
      expect(group_topics).to include('haskell', 'html')
    end

    it "gets all users for a group" do
      group_1_users = db.get_group(@group_1.id, users: true).users
      expect(group_1_users).to include(mario, luigi)
      expect(group_1_users).to_not include(peach)
    end
  end
end