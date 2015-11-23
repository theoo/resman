class UsersController < ApplicationController

  def index
    @q = User.search(params[:q])
    @users = @q.result.page(params[:page])
  end

  def show
    redirect_to(action: :edit)
  end

  def new
    @user = User.new(group_id: params[:group_id])

  end

  def edit
    @user = User.find(params[:id])

  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to(users_path)
    else
      render action: 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(@user)
    else
      render action: 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    User.transaction { @user.destroy }
    redirect_to(users_url)
  end
end
