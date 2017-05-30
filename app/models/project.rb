class Project < ActiveRecord::Base
  has_many :results, dependent: :delete_all

  validates :project_name, presence: true

  def self.options_for_select
    order('LOWER(project_name)').map {|e| [e.project_name, e.id]}
  end

  def self.create_new_project(params)
    project = Project.new(
        project_name: params['project_name']
    )
    project.save
    project
  end

  def self.edit_project(project, params)
    project.update(
        project_name: params[:project_name]
    )
    project
  end


end