class RequestFile < ActiveRecord::Base

  mount_uploader :file, ResultUploader

end