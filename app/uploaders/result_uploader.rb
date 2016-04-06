# encoding: utf-8

class ResultUploader < CarrierWave::Uploader::Base


  storage :file

  def store_dir
    "#{Rails.root}/storage/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp"
  end


  def extension_white_list
    %w(csv)
  end


end
