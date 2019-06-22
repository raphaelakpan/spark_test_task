require "spec_helper"

RSpec.describe Spree::Admin::ProductsController do
  stub_authorization!

  render_views

  describe "GET #upload" do
    it "renders the products upload form" do
      get :upload

      assert_template :upload
      expect(response).to have_http_status(200)
      expect(response.body).to have_content(I18n.t("products.upload.text"))
      expect(response.body).to have_content(I18n.t("products.upload.select_file"))
      expect(response.body).to have_content(I18n.t("upload"))
    end
  end

  describe "POST #upload_products" do
    context "when file has invalid format" do
      it "displays an error message to the user" do
        allow(UploadProducts).to receive(:valid_file_format?) { false }

        post :process_upload

        assert_template :upload
        expect(response).to have_http_status(200)
        expect(response.body).to have_content(I18n.t("products.upload.file_error"))
      end
    end

    context "when file is a CSV file" do
      let(:file) { "CSV File" }
      let(:upload_products) do
        instance_double(
          "UploadProducts",
          perform: nil,
          total: 3,
          processed: 2,
          errors: ["Price is required"]
        )
      end

      it "processes the CSV and displays the results" do
        allow(UploadProducts).to receive(:valid_file_format?) { true }
        allow(UploadProducts).to receive(:new).with(file) { upload_products }

        post :process_upload, params: { file: file }

        assert_template :process_upload
        expect(response).to have_http_status(200)
        expect(response.body).to have_content(I18n.t("products.upload.results"))
        expect(response.body).to have_content(I18n.t("products.upload.total", count: 3))
        expect(response.body).to have_content(I18n.t("products.upload.processed", count: 2))
        expect(response.body).to have_content(I18n.t("products.upload.errors", count: 1))
        expect(response.body).to have_content("Price is required")
      end
    end
  end
end
