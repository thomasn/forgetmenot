# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

class AccountController < ApplicationController
	layout 'account'
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :redirect_to_signup_if_no_users, :except => ['signup', 'logout']
  before_filter :login_required, :only => ['signup'] if User.count > 0
  before_filter :login_from_cookie, :except => ['signup']
  # say something nice, you goof!  something sweet.

  def index
    if logged_in?
      redirect_to '/'
    else
      redirect_to :action => 'login'
    end
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
  
  def redirect_to_signup_if_no_users
    return true if User.count > 0
    
    redirect_to :action => 'signup'
    return false
  end
end
