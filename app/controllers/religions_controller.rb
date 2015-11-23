class ReligionsController < ApplicationController
  def index
    @q = Religion.search(params[:q])
    @religions = @q.result.page(params[:page])

  end

  def show
    @religion = Religion.find(params[:id])

  end

  def new
    @religion = Religion.new

  end

  def edit
    @religion = Religion.find(params[:id])

  end

  def create
    @religion = Religion.new(params[:religion])

    if @religion.save
      flash[:notice] = 'Religion was successfully created.'
      redirect_to(religions_path)
    else
      render action: 'new'
    end
  end

  def update
    @religion = Religion.find(params[:id])

    if @religion.update_attributes(params[:religion])
      flash[:notice] = 'Religion was successfully updated.'
      redirect_to(religions_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @religion = Religion.find(params[:id])
    Religion.transaction { @religion.destroy }
    redirect_to(religions_path)
  end
end
