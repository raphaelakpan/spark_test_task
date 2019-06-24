require "spec_helper"

RSpec.describe Spree::Admin::ProductsController do
  stub_authorization!

  render_views

  let(:admin_user) { create(:user, :admin) }

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
    let(:file_upload) { create(:file_upload) }

    before do
      allow(controller).to receive(:spree_current_user) { admin_user }
    end

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
      let(:file_path) { "files/valid-products-csv.csv" }
      let(:upload_products) do
        instance_double(
          "UploadProducts",
          perform: nil,
          total: 3,
          processed: 2,
          errors: ["Price is required"]
        )
      end

      before do
        allow(UploadProducts).to receive(:valid_file_format?) { true }
      end

      it "creates a FileUpload record and enqueues UploadProductsJob to process the file upload" do
        expect(FileUpload).to receive(:create_upload).with(file_path, admin_user.id) { file_upload }
        expect(UploadProductsJob).to receive(:perform_async).with(file_path, file_upload.id)

        post :process_upload, params: { file: file_path }
      end

      it "redirects to the upload status page" do
        expect(FileUpload).to receive(:create_upload).with(file_path, admin_user.id) { file_upload }
        expect(
          post :process_upload, params: { file: file_path }
        ).to redirect_to(admin_products_upload_status_path(upload_id: file_upload.id))
      end
    end
  end

  describe "GET #upload_status" do
    let(:file_upload) do
      create(
        :file_upload,
        file_name: "awesome-csv.csv",
        state: FileUpload::STATES[:done],
        error_data: ["Row 2 isn't that great :)"],
        metadata: {
          processed: 4,
          total:5
        }
      )
    end

    before do
      allow(controller).to receive(:spree_current_user) { admin_user }
    end

    context "when file_upload is found" do
      before do
        allow(FileUpload).to receive(:file_upload_for)
          .with(file_upload.id.to_s, admin_user.id) { file_upload }
      end

      it "renders the upload_status template" do
        get :upload_status, params: { upload_id: file_upload.id }

        assert_template :upload_status

        expect(response).to have_http_status(200)
      end

      it "displays results about the file upload" do
        get :upload_status, params: { upload_id: file_upload.id }

        expect(response.body).to have_content(I18n.t("products.upload.results"))
        expect(response.body).to have_content("awesome-csv.csv")
        expect(response.body).to have_content(I18n.t("products.upload.state.done"))
        expect(response.body).to have_content(I18n.t("products.upload.total", count: 5))
        expect(response.body).to have_content(I18n.t("products.upload.processed", count: 4))
        expect(response.body).to have_content(I18n.t("products.upload.errors", count: 1))
        expect(response.body).to have_content("Row 2 isn't that great :)")
      end
    end

    context "when file_upload is not found" do
      it "redirects to products upload page" do
        expect(
          get :upload_status
        ).to redirect_to(admin_products_upload_path)
      end
    end
  end
end
