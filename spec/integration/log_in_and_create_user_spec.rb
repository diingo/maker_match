require 'spec_helper'

describe 'Log In and Create User' do
  let(:interest_1) { GladiatorMatch.db.create_interest(name: 'haskell', expertise: 'advanced')}
  let(:login_res) { GladiatorMatch::LogIn.run(github_login: 'plum_pits') }

  before do
    @params_user = {
      first_name: 'Plum',
      last_name: 'Pits',
      github_login: login_res.github_login,
      location: '77478',
      remote: true,
      interests: [interest_1]
    }

    Geocoder.stub(:coordinates).with('77478').and_return([29.6185208, -95.6090009])
  end

  it "logs in, creates a user, and adds the user id to the session" do
    expect(login_res.success?).to eq(true)

    s_key = login_res.session_key
    create_user_res = GladiatorMatch::CreateUser.run(@params_user)

    expect(create_user_res.success?).to eq(true)

    # note: session key is same as session id here
    updated_session = GladiatorMatch.db.get_session(s_key)
    updated_session[:user_id] = create_user_res.user.id

    GladiatorMatch.db.update_session(updated_session)

    retrieved_session = GladiatorMatch.db.get_session(s_key)
    expect(retrieved_session[:user_id]).to_not be_nil
    expect(retrieved_session[:user_id]).to eq(create_user_res.user.id)
  end
end