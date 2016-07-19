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
    redirect_to @attachment.attachable
  end

  def show
    @attachment = Attachment.find(params[:id])
    send_file @attachment.file.path
  end

  def edit
    @attachment = Attachment.find(params[:id])
    render 'form'
  end

  def update
    @attachment = Attachment.find(params[:id])
    @attachment.update_attributes(attachment_params)

    flash[:notice] = "Attachment successfully updated."
    redirect_to @attachment.attachable
  end

  def destroy
    @attachment = Attachment.find(params[:id]).destroy
    flash[:notice] = "Attachment successfully removed."
    redirect_to @attachment.attachable
  end

  private

    def attachment_params
      params.require(:attachment).permit(:title, :file, :attachable_type, :attachable_id)
    end

end
