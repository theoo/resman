class RulesController < ApplicationController
  before_filter   :load_rate
  
  def load_rate
    @rate = Rate.find(params[:rate_id])
  end

  def index
    @rules = @rate.rules
    @rules_count = @rules.size
    
  end

  def new
    @rule = Rule.new(rate: @rate)
    
  end

  def edit
    @rule = Rule.find(params[:id])
    
  end

  def create
    @rule = Rule.new(params[:rule])
    if @rule.save
      flash[:notice] = 'Rule was successfully created.'
      redirect_to(rate_rules_path(@rate))
    else
      render action: 'new'
    end
  end

  def update
    @rule = Rule.find(params[:id])
    if @rule.update_attributes(params[:rule])
      flash[:notice] = 'Rule was successfully updated.'
      redirect_to(rate_rules_path(@rate))
    else
      render action: 'edit'
    end
  end

  def destroy
    @rule = Rule.find(params[:id])
    @rule.destroy
    redirect_to(rate_rules_path(@rate))
  end
end
