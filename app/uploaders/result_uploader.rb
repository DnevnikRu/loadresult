# encoding: utf-8

class ResultUploader < CarrierWave::Uploader::Base


  storage :file

  def store_dir
    base_part = if Rails.configuration.x.storage_path.empty?

                  "#{Rails.root}/storage"
                else
                  Rails.configuration.x.storage_path
                end
    "#{base_part}/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp"
  end

end
