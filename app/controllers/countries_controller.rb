class CountriesController < ApplicationController
  def index
    @q = Country.search(params[:q])
    @countries = @q.result.page(params[:page])
  end

  def show
    @country = Country.find(params[:id])

  end

  def new
    @country = Country.new

  end

  def edit
    @country = Country.find(params[:id])

  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:notice] = 'Country was successfully created.'
      redirect_to(countries_path)
    else
      render action: 'new'
    end
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:notice] = 'Country was successfully updated.'
      redirect_to(countries_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @country = Country.find(params[:id])
    Country.transaction { @country.destroy }
    redirect_to(countries_path)
  end
end
