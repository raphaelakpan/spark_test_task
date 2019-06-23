require "spec_helper"

describe UploadProducts do
  # file has 3 rows - 2 valid rows and 1 invalid row
  let(:file) { fixture_file_upload('files/valid-products-csv.csv', 'text/csv') }

  describe "::valid_file_format?" do
    context "when file format is CSV" do
      it "returns true" do
        expect(described_class.valid_file_format?(file)).to be true
      end
    end

    context "when file format is not CSV" do
      let(:file) { fixture_file_upload('files/invalid-products-csv.txt', 'text/plain') }

      it "returns false" do
        expect(described_class.valid_file_format?(file)).to be false
      end
    end

    context "when file is nil" do
      let(:file) { nil }

      it "returns false" do
        expect(described_class.valid_file_format?(file)).to be false
      end
    end
  end

  describe "#perform" do
     # slug contained in CSV file
     let(:slug) { "ruby-on-rails-bag" }

     it "uploads the CSV" do
      expect {
        described_class.new(file).perform
      }.to change(Spree::Product, :count).by(2)
    end

    it "tracks total, proccessed and errors rows" do
      upload_products = described_class.new(file)
      upload_products.perform

      expect(upload_products.total).to eq 3
      expect(upload_products.processed).to eq 2
      expect(upload_products.errors.size).to eq 1
      expect(
        upload_products.errors.first =~ /Row 3: Must supply price for variant or master/
      ).to be_truthy
    end


    describe "slug" do
      # record in CSV file with for slug "ruby-on-rails-bag";
      let(:csv_row_params) do
        {
          slug: slug,
          name: "Ruby on Rails Bag",
          description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
          price: "22,99",
          availability_date: "2017-12-04T14:55:22.913Z"
        }
      end

      context "when slug already exists" do
        # create existing product
        let!(:existing_product) { create(:product, slug: slug, name: "Existing Product") }

        it "updates the product with the values in the CSV" do
          described_class.new(file).perform

          existing_product.reload
          expect(existing_product.slug).to eq slug
          expect(existing_product.name).to eq csv_row_params[:name]
          expect(existing_product.description).to eq csv_row_params[:description]
          expect(existing_product.price.to_f).to eq csv_row_params[:price].sub(",", ".").to_f
          expect(existing_product.available_on).to eq DateTime.parse(csv_row_params[:availability_date])
        end
      end

      context "when slug does not exists" do
        it "creates a new product with the values in the CSV" do
          expect(Spree::Product.find_by(slug: slug).class).to eq NilClass

          described_class.new(file).perform

          new_product = Spree::Product.find_by(slug: slug)
          expect(new_product.slug).to eq slug
          expect(new_product.name).to eq csv_row_params[:name]
          expect(new_product.description).to eq csv_row_params[:description]
          expect(new_product.price.to_f).to eq csv_row_params[:price].sub(",", ".").to_f
          expect(new_product.available_on).to eq DateTime.parse(csv_row_params[:availability_date])
        end
      end
    end

    describe "'stock_total' => count_on_hand" do
      # 'stock_total' field in CSV to map with count_on_hand for slug "ruby-on-rails-bag"
      let(:stock_total) { 15 }

      context "when stock_item already exists for the product" do
        let!(:existing_product) { create(:product, :in_stock, slug: slug, name: "Existing Product") }
        let(:stock_item) { existing_product.stock_items.first }

        it "updates the stock_item's count_on_hand to the value of 'stock_total'" do
          expect(stock_item.count_on_hand).to eq 10

          described_class.new(file).perform

          expect(stock_item.reload.count_on_hand).to eq stock_total
        end
      end

      context "when stock item does not exists for the product" do
        it "adds a stock_item record with count_on_hand set to the value of 'stock_total'" do
          expect(Spree::Product.find_by(slug: slug)).to be nil

          described_class.new(file).perform

          stock_item = Spree::Product.find_by(slug: slug).stock_items.first
          expect(stock_item).not_to be nil
          expect(stock_item.count_on_hand).to eq stock_total
        end
      end
    end

    describe "'category' => taxon" do
      # 'category' field in CSV to map with taxon for slug "ruby-on-rails-bag"
      let(:category) { "Bags"}

      context "when taxon that matches the 'category' field already exists for the product" do
        let(:taxon) { create(:taxon, name: category) }
        let!(:existing_product) { create(:product, slug: slug, name: "Existing Product", taxons: [taxon]) }

        it "does not add a new taxon record for the product" do
          expect(existing_product.taxons).to eq [taxon]

          described_class.new(file).perform

          existing_product.reload
          expect(existing_product.taxons).to eq [taxon]
        end
      end

      context "when no taxon matches the 'category' field for the product" do
        let!(:existing_product) { create(:product, slug: slug, name: "Existing Product") }

        it "adds a new taxon record for the product" do
          expect(existing_product.taxons).to eq []

          described_class.new(file).perform

          taxon = Spree::Taxon.find_by(name: category)

          existing_product.reload
          expect(existing_product.taxons).to eq [taxon]
        end
      end
    end
  end
end
