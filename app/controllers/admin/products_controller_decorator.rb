module Admin
  module ProductsControllerDecorator
    def self.prepended(base)
      base.before_action :authorize_admin, only: [:upload, :process_upload, :upload_status]
    end

    def upload
    end

    def process_upload
      file = file_params["file"]
      unless UploadProducts.valid_file_format?(file)
        flash.now[:error] = I18n.t("products.upload.file_error")
        return render :upload
      end

      file_upload = FileUpload.create_upload(file, spree_current_user)
      UploadProductsJob.perform_async(file.path, file_upload.id)

      flash[:notice] = I18n.t("products.upload.processing")
      redirect_to admin_products_upload_status_path(id: file_upload.id)
    end

    def upload_status
      @file_upload = FileUpload.file_upload_for(params[:id], spree_current_user)
      if @file_upload.nil?
        flash[:notice] = I18n.t("products.upload.status_error")
        redirect_to admin_products_upload_path
      end
    end

    private

    def authorize_admin
      authorize! :create, Spree::Product
    end

    def file_params
      params.permit(:file)
    end
  end
end

Spree::Admin::ProductsController.prepend Admin::ProductsControllerDecorator
