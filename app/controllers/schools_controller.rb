class SchoolsController < ApplicationController
  def index
    @search = School.new_search(params[:search])
    @schools, @schools_count = @search.all, @search.count
    
  end

  def show
    @school = School.find(params[:id])
    render  
  end

  def new
    @school = School.new
    
  end

  def edit
    @school = School.find(params[:id])
    
  end

  def create
    @school = School.new(params[:school])

    if @school.save
      flash[:notice] = 'School was successfully created.'
      redirect_to(schools_path)
    else
      render action: 'new'
    end
  end

  def update
    @school = School.find(params[:id])

    if @school.update_attributes(params[:school])
      flash[:notice] = 'School was successfully updated.'
      redirect_to(schools_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @school = School.find(params[:id])
    School.transaction { @school.destroy }
    redirect_to(schools_path)
  end
end
