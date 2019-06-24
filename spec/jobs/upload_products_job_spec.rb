require "spec_helper"

RSpec.describe UploadProductsJob do
  describe "#perform" do
    let(:file_path) { "temp/awesome-path.csv" }
    let(:file_upload_id) { 45 }
    let(:upload_products) { instance_double("UploadProducts", perform: nil) }

    it "calls UploadProducts service with file_path and file_upload_id" do
      expect(UploadProducts).to receive(:new).with(file_path, file_upload_id) { upload_products }
      expect(upload_products).to receive(:perform)

      described_class.new.perform(file_path, file_upload_id)
    end
  end
end
