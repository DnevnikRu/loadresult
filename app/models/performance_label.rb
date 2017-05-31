class PerformanceLabel < ActiveRecord::Base
   belongs_to :performance_group

   validates :label, presence: true

   def self.create_new_label(params)
      label = PerformanceLabel.new(
          performance_group_id: params['id'],
          label: params['label'],
      )
      label.save
      label
   end

  def self.edit_label(label, params)
     label.update(
         label: params[:label]
     )
     label
  end

end