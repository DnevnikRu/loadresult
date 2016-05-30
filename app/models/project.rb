class Project < ActiveRecord::Base
  has_many :results

  def self.options_for_select
    order('LOWER(project_name)').map { |e| [e.project_name, e.id] }
  end
end