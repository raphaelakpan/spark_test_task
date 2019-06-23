module Admin
  module ProductsControllerDecorator
    def self.prepended(base)
      base.before_action :authorize_admin, only: [:upload, :process_upload]
    end

    def upload
    end

    def process_upload
      unless UploadProducts.valid_file_format?(file_params["file"])
        flash.now[:error] = I18n.t("products.upload.file_error")
        return render :upload
      end

      @upload_products = UploadProducts.new(file_params["file"])
      @upload_products.perform

      flash.now[:success] = I18n.t("products.upload.success")
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
