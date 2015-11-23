class InstitutesController < ApplicationController
  def index
    @q = Institute.search(params[:q])
    @institutes = @q.result.page(params[:page])

  end

  def show
    @institute = Institute.find(params[:id])

  end

  def new
    @institute = Institute.new

  end

  def edit
    @institute = Institute.find(params[:id])

  end

  def create
    @institute = Institute.new(params[:institute])
    if @institute.save
      flash[:notice] = 'Institute was successfully created.'
      redirect_to(institutes_path)
    else
      render action: 'new'
    end
  end

  def update
    @institute = Institute.find(params[:id])
    if @institute.update_attributes(params[:institute])
      flash[:notice] = 'Institute was successfully updated.'
      redirect_to(institutes_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @institute = Institute.find(params[:id])
    Institute.transaction { @institute.destroy }
    redirect_to(institutes_path)
  end
end
