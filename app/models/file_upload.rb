class FileUpload < ApplicationRecord
  belongs_to :creator, class_name: "Spree::User"

  validates :creator, presence: true

  serialize :error_data, Array

  STATES = {
    pending: "pending",
    done: "done",
    processing: "processing",
    error: "error"
  }

  def self.create_upload(file, creator)
    create!(
      file_name: file.original_filename,
      file_type: file.content_type,
      creator: creator
    )
  end

  def self.file_upload_for(id = nil, creator)
    return where(creator: creator).last if id.nil?
    where(id: id, creator: creator).first
  end

  def processing?
    state == STATES[:processing]
  end

  def done?
    state == STATES[:done]
  end

  def pending?
    state == STATES[:pending]
  end

  def error?
    state == STATES[:error]
  end
end
