class CommentsController < ApplicationController
  before_action :set_project

  def index
    @comment = Comment.new
    @comments = @project.comments.order(created_at: params.fetch(:order, :asc))
  end

  def create
    @comment = @project.comments.build(permitted_params.merge(user: current_user)) if current_user.present?
    @comment = @project.comments.build(permitted_params) if current_user.blank?
    if @comment.save
      CommentMailer.delay.comment_made(@comment)
      flash[:notice] = "Your comment has been submitted successfully!"
      respond_with @comment, location: project_path(@project)
    else
      error_message = @comment.errors.full_messages.to_sentence
      error_message += "<br/>#{@comment.body}" if @comment.errors.messages[:body] && @comment.body.present?
      redirect_to project_path(@project), alert: error_message.html_safe
    end
  end

  def update
    @comment = Comment.find_by(id: params[:id])
    @comment.update_attributes(body: params[:comment][:body], project_id: params[:comment][:project_id])
    CommentMailer.delay.comment_made(@comment)
    flash[:notice] = "Your comment has been updated successfully!"
    respond_with @comment, location: project_path(params[:comment][:project_id])
  end

  private

    def permitted_params
      params.require(:comment).permit :body, :commentable_id, :commentable_type
    end

    def set_project
      @project = Project.find params[:project_id]
    end
end
