class RatesController < ApplicationController
  def index
    @search = Rate.new_search(params[:search])
    @rates, @rates_count = @search.all, @search.count
    
  end

  def show
    @rate = Rate.find(params[:id])
    
  end

  def new
    @rate = Rate.new
    
  end

  def edit
    @rate = Rate.find(params[:id])
    
  end

  def create
    @rate = Rate.new(params[:rate])

    if @rate.save
      flash[:notice] = 'Rate was successfully created.'
      redirect_to(rates_path)
    else
      render action: 'new'
    end
  end

  def update
    @rate = Rate.find(params[:id])

    if @rate.update_attributes(params[:rate])
      flash[:notice] = 'Rate was successfully updated.'
      redirect_to(rates_path)
    else
      render action: 'edit'
    end
  end

  def destroy
    @rate = Rate.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @rate.deletable?
    Rate.transaction { @rate.destroy }
    redirect_to(rates_path)
  end
end
