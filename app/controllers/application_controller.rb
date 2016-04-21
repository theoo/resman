class ApplicationController < ActionController::Base

  # UI don't relay CSRF, need to upgrade all views in a first place !
  # protect_from_forgery

  helper :all

  helper_method :logged_in?
  helper_method :current_user
  helper_method :has_access?

  before_filter :login_required , :rights_required, :set_current_user

  def self.actions
    (self.action_methods - ApplicationController.action_methods).sort
  end

  def controller_to_model
    controller_name.singularize.camelize.constantize
  end

  def login_required
    redirect_to(login_path) unless logged_in?
  end

  def rights_required
    return if current_user.id == params[:id].try(:to_i) && self.class.to_s == 'UsersController' && self.action_name == 'edit'
    redirect_to(denied_path) unless current_user.has_access?(self.class.to_s, self.action_name)
  end

  def logged_in?
    current_user != nil
  end

  def current_user
    @current_user ||= session[:user] ? User.find(session[:user]) : nil
    User.first
  end

  def set_current_user
    User.current_user = current_user
  end

  def has_access?(controller, action)
    current_user.has_access?(controller, action)
  end

  def current_user=(user)
    if user.is_a?(User)
      session[:user] = user.id
      @current_user = user
    else
      session[:user] = User.current_user = nil
    end
  end
end