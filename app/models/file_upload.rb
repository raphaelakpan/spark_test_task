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

  def self.create_upload(file, creator_id)
    create!(
      file_name: file.original_filename,
      file_type: file.content_type,
      creator_id: creator_id
    )
  end

  def self.file_upload_for(id = nil, creator_id)
    return where(creator_id: creator_id).last if id.nil?
    where(id: id, creator_id: creator_id).first
  end

  def processing?
    state == STATES[:processing]
  end

  def processing
    update(state: STATES[:processing])
  end

  def done?
    state == STATES[:done]
  end

  def done
    update(state: STATES[:done])
  end

  def pending?
    state == STATES[:pending]
  end

  def pending
    update(state: STATES[:pending])
  end

  def error?
    state == STATES[:error]
  end

  def error
    update(state: STATES[:error])
  end
end
