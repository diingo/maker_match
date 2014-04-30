require 'spec_helper'

describe GladiatorMatch::Database::InMemory do
  let(:db) { described_class.new }
  before { db.clear_everything }

  describe 'Users' do
    it "creates a user" do
      user = db.create_user :first_name => 'Mario', :last_name => 'Mario', :email => 'mario@example.com', :github_login => 'mario_mario'
      expect(user).to be_a GladiatorMatch::User
      expect(user.first_name).to eq 'Mario'
      expect(user.id).to_not be_nil
    end

    it "gets a user" do
      user = db.create_user :first_name => 'Luigi', :last_name => 'Mario', :email => 'luigi@example.com', :github_login => 'luigi_mario'
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
end