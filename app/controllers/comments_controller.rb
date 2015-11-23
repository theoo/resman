class CommentsController < ApplicationController
  def ajax_comment_read
    comment = Comment.find(params[:comment_id])
    comment.read = (params[:read] == "true")
    comment.save!
    render nothing: true
  end

  def index
    @search = Comment.new_search(params[:search])
    unless @search.order_by
      @search.order_by = :created_at
      @search.order_as = :desc
    end
    @comments, @comments_count = @search.all, @search.count
    
  end

  def show
    @comment = Comment.find(params[:id])
    
  end

  def new
    @comment = Comment.new
    
  end

  def edit
    @comment = Comment.find(params[:id])
    
  end

  def create
    @comment = Comment.new(params[:comment])

    if @comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to(:back)
    else
      render action: 'new'
    end
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully updated.'
      redirect_to( action: 'index' )
    else
      render action: 'edit'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to(comments_url)
  end
end
