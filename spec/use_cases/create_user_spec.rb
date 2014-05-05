require 'spec_helper'

describe GladiatorMatch::CreateUser, pending: true do
  (:interest_1) {} 
  (:result) { described_class.run(@params) }
  before do
    @params = { first_name: 'Plum', last_name: 'Pits', github_login: 'plum_pits', location: '7748', interests: []}
  end
end