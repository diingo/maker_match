class SessionsController < ApplicationController
  def create
    binding.pry
    # auth_hash["extra"]["raw_info"]["login"] is where the login is located
    @user = User.find_or_create_from_auth_hash(auth_hash)
    self.current_user = @user
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
