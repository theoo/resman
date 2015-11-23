class OptionsController < ApplicationController  
  def index
    @options = Option.find(:all)
    
  end

  def show
    redirect_to(action: :edit)
  end
  
  def edit
    @option = Option.find(params[:id])
    render 
  end

  def update
    @option = Option.find(params[:id])
    if @option.update_attributes(params[:option])
      flash[:notice] = 'Option was successfully updated.'
      redirect_to(action: :index)
    else
      render action: 'show'
    end
  end
end
