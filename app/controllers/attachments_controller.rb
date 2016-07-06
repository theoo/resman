class AttachmentsController < ApplicationController

  before_filter do

  end

  def new
    @object = params[:class].constantize.find(params[:id])
    @attachment = @object.attachments.new

    render 'form'
  end

  def create
    @attachment = Attachment.create(attachment_params)

    flash[:notice] = "Attachment successfully created."
    render 'form'
  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

    def attachment_params
      params.require(:attachment).permit(:title, :file, :attachable_type, :attachable_id)
    end

end
