class ActivitiesController < ApplicationController
  def index
    @q = Activity.search(params[:q])
    @activities = @q.result.page(params[:page])
  end
end
