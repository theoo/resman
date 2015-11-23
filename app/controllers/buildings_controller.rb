class BuildingsController < ApplicationController
  def index
    @search = Building.new_search(params[:search])
    @buildings, @buildings_count = @search.all, @search.count
    
  end

  def show
    @building = Building.find(params[:id])
    
  end

  def new
    @building = Building.new
    
  end

  def edit
    @building = Building.find(params[:id])
    
  end

  def create
    @building = Building.new(params[:building])
    if @building.save
      flash[:notice] = 'Building was successfully created.'
      redirect_to(buildings_path)
    else
      render action: 'new'
    end
  end

  def update
    @building = Building.find(params[:id])
    if @building.update_attributes(params[:building])
      flash[:notice] = 'Building was successfully updated.'
      redirect_to(buildings_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @building = Building.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @building.deletable?
    Building.transaction { @building.destroy }
    redirect_to(buildings_path)
  end
end
