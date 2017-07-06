class PerformanceFile < ActiveRecord::Base

  mount_uploader :file, ResultUploader

end