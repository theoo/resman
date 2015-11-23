class GroupsController < ApplicationController
  def index
    @q = Group.search(params[:q])
    @groups = @q.result.page(params[:page])

  end

  def show
    # TODO only searchlogic for rights atm, do it for users too
    @group = Group.find(params[:id])
    @q = @group.rights.search(params[:q])
    @rights, @rights_count = @q.result.page(params[:page]), @q.count

  end

  def new
    @group = Group.new

  end

  def create
    @group = Group.new(params[:group])

    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to(@group)
    else
      render action: 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])

  end

  def update
    @group = Group.find(params[:id])

    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to(@group)
    else
      render action: 'edit'
    end
  end

  def destroy
    @group = Group.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @group.deletable?
    group.transaction { @group.destroy }
    redirect_to(groups_url)
  end

  def manage_rights
    @group = Group.find(params[:id])

  end

  def update_rights
    group = Group.find(params[:id])
    Group.transaction do
      group.rights.destroy_all
      params[:selected].each do |str|
        controller, action = str.split
        group.rights.create!(controller: controller, action: action, allowed: true)
     end
    end
    redirect_to(group_path(group))
  end
end
