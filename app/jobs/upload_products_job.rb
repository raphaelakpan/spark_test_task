class UploadProductsJob
  include Sidekiq::Worker

  def perform(file_path, file_upload_id)
    UploadProducts.new(file_path, file_upload_id).perform
  end
end
