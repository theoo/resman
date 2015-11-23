class RoomOptionsController < ApplicationController
  before_filter   :load_room
  
  def load_room
    @room = Room.find(params[:room_id])
  end

  def index
    @room_options = @room.options
    @room_options_count = @room_options.size    
    
  end

  def show
    @room_option = RoomOption.find(params[:id])
    
  end

  def new
    @room_option = RoomOption.new(room: @room)
    
  end

  def edit
    @room_option = RoomOption.find(params[:id])
    
  end

  def create
    @room_option = RoomOption.new(params[:room_option])

    if @room_option.save
      flash[:notice] = 'RoomOption was successfully created.'
      redirect_to(room_room_options_path(@room))
    else
      render action: 'new'
    end
  end

  def update
    @room_option = RoomOption.find(params[:id])

    if @room_option.update_attributes(params[:room_option])
      flash[:notice] = 'RoomOption was successfully updated.'
      redirect_to(room_room_options_path(@room))
    else
      render action: 'edit'
    end
  end

  def destroy
    @room_option = RoomOption.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @room_option.deletable?
    @room_option.destroy
    redirect_to(room_room_options_path(@room))
  end
end
