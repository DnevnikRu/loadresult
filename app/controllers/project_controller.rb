class ProjectController < ApplicationController
  before_action :set_project, only: [:edit, :update, :destroy]

  def index
    @projects = Project.all.order('id ASC')
  end

  def create
    project = Project.create_new_project(params)
    if project.errors.empty?
      flash[:notice] = 'Project was successfully created.'
      redirect_to :back
    else
      flash.now[:project_name] = params[:project_name]
      flash[:alert] = project.errors.full_messages
      redirect_to :back
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = 'Project was successfully destroyed.'
    redirect_to :back
  end

  def edit
    flash.now[:project_name] = @project[:project_name]
  end

  def update
    project = Project.edit_project(@project, params)
    if project.errors.empty?
      redirect_to(project_index_path, notice: 'Project name was successfully updated.')
    else
      flash.now[:project_name] = params[:project_name]
      flash.now[:alert] = project.errors.full_messages
      render action: :edit
    end
  end

  private

  def set_project
    @project = Project.find_by(id: params[:id])
  end

end