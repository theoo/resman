class ContinentsController < ApplicationController
  def index
    @q = Continent.search(params[:q])
    @continents = @q.result.page(params[:page])

  end

  def show
    @continent = Continent.find(params[:id])

  end

  def new
    @continent = Continent.new

  end

  def edit
    @continent = Continent.find(params[:id])

  end

  def create
    @continent = Continent.new(params[:continent])
    if @continent.save
      flash[:notice] = 'Continent was successfully created.'
      redirect_to(continents_path)
    else
      render action: 'new'
    end
  end

  def update
    @continent = Continent.find(params[:id])
    if @continent.update_attributes(params[:continent])
      flash[:notice] = 'Continent was successfully updated.'
      redirect_to(continents_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @continent = Continent.find(params[:id])
    Continent.transaction { @continent.destroy }
    redirect_to(continents_path)
  end
end
