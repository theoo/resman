class ActivitiesController < ApplicationController
  def index
    @search = Activity.new_search(params[:search])
    unless @search.order_by
      @search.order_by = :created_at
      @search.order_as = :desc
    end
    @activities, @activities_count = @search.all, @search.count
    
  end
end
