class RoomsController < ApplicationController

  def index
    @search = Room.new_search(params[:search])
    @rooms, @rooms_count = @search.all, @search.count
    
  end

  def new
    @room = Room.new
    
  end

  def edit
    @room = Room.find(params[:id])
    
  end

  def create
    @room = Room.new(params[:room])

    if @room.save
      flash[:notice] = 'Room was successfully created.'
      redirect_to(rooms_path)
    else
      render action: 'new'
    end
  end

  def update
    @room = Room.find(params[:id])

    if @room.update_attributes(params[:room])
      flash[:notice] = 'Room was successfully updated.'
      render action: :edit
    else
      render action: 'edit'
    end
  end

  def destroy
    @room = Room.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @room.deletable?
    Room.transaction { @room.destroy }
    redirect_to(rooms_path)
  end
end
