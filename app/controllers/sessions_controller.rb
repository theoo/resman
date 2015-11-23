class SessionsController < ApplicationController
  skip_before_filter :login_required, :rights_required

  def new

  end

  def denied

  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])

    if logged_in?
      # Find a page the user has right to
      right = self.current_user.right_for('OverviewController', 'summary')
      right = self.current_user.right_for('ReservationsController', 'index') unless right.allowed?
      right = self.current_user.right_for('ResidentsController', 'index') unless right.allowed?
      right = self.current_user.right_for('InvoicesController', 'index') unless right.allowed?
      right = self.current_user.rights.where(allowed: true).first unless right.allowed?
      redirect_to(controller: right.controller[/^(\w+)Controller$/, 1].downcase, action: right.action)
    else
      flash.now[:error] = 'Username/password mismatch.'
      render action: 'new'
    end
  end

  def destroy
    self.current_user = nil
    reset_session
    redirect_to(login_path)
  end
end

