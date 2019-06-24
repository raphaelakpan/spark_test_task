# Class to process Products CSV file upload
class UploadProducts
  require 'csv'

  def initialize(file_path, file_upload_id)
    @file_path = file_path
    @processed = 0
    @total = 0
    @errors = []
    @file_upload = FileUpload.find(file_upload_id)
  end

  def perform
    @file_upload.processing
    process_file
    update_file_upload
  rescue
    @file_upload.error
  end

  def self.valid_file_format?(file)
    return false unless file.try(:content_type).present?
    file.content_type == "text/csv"
  end

  private

  def update_file_upload
    @file_upload.update(
      error_data: @errors,
      metadata: {
        processed: @processed,
        total: @total
      },
      state: FileUpload::STATES[:done]
    )
  end

  def process_file
    CSV.foreach(@file_path, headers: true, col_sep: ";") do |row|
      process_row(row.to_h)
    end
  end

  def process_row(row)
    ActiveRecord::Base.transaction do
      product = Spree::Product.find_by(slug: row["slug"])

      if product.present?
        update_product(product, row)
      else
        product = create_new_product(row)
      end

      add_taxon(product, row["category"])
      update_stock_item_count(product, row["stock_total"])
    end

    @processed += 1
  rescue => e
    handle_error(e)
  ensure
    @total += 1
  end

  def update_product(product, row)
    product.update!(product_params(row).except(:slug))
  end

  def create_new_product(row)
    Spree::Product.create!(product_params(row))
  end

  def product_params(row)
    {
      name: row["name"],
      price: row["price"] && row["price"].sub(",", ".").to_f,
      description: row["description"],
      available_on: row["availability_date"],
      slug: row["slug"],
      shipping_category: default_shipping_category
    }
  end

  def add_taxon(product, name)
    return if product.taxons.where(name: name).exists?

    taxon = Spree::Taxon.where(name: name).first_or_create
    product.taxons << taxon
  end

  def update_stock_item_count(product, count)
    return unless count.to_i.positive?

    stock_item = product.master.stock_items.first_or_initialize(
      stock_location: default_stock_location
    )
    stock_item.count_on_hand = count
    stock_item.save!
  end

  def handle_error(e)
    message = if e.try(:record).present?
                e.record.errors.full_messages.join(", ")
              else
                e.message.sub(/.+:/, "")
              end

    @errors << "Row #{@total + 1}: #{message}"
  end

  def default_shipping_category
    @_default_shipping_category ||= Spree::ShippingCategory.first_or_create!(name: "default")
  end

  def default_stock_location
    @_default_stock_location ||= Spree::StockLocation.first_or_create!(name: "default")
  end
end
