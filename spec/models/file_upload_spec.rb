RSpec.describe FileUpload do
  let(:creator) { create(:user) }
  let(:file_upload) { create(:file_upload) }

  it "has a valid factory" do
    expect(build(:file_upload)).to be_valid
  end

  describe "validations" do
    it "requires a creator" do
      expect(build(:file_upload, creator: nil)).not_to be_valid
    end
  end

  describe "::create_upload" do
    let(:file) { double("File", original_filename: "awesome.csv", content_type: "text/csv") }

    it "creates a new record for the file and creator" do
      expect {
        FileUpload.create_upload(file, creator.id)

        expect(FileUpload.last).to have_attributes(
          file_name: "awesome.csv",
          file_type: "text/csv",
          creator_id: creator.id
        )
      }.to change(FileUpload, :count).by(1)
    end
  end

  describe "::file_upload_for" do
    let!(:file_upload) { create(:file_upload, creator: creator) }
    let!(:file_upload_2) { create(:file_upload, creator: creator) }

    context "when 'id' is nil" do
      it "returns the last file_upload for the user" do
        expect(FileUpload.file_upload_for(nil, creator.id)).to eq file_upload_2
      end
    end

    context "when 'id' is present" do
      it "returns the file_upload record" do
        expect(FileUpload.file_upload_for(file_upload.id, creator.id)).to eq file_upload
      end
    end

    context "no record is found" do
      let!(:creator_2) { create(:user) }

      it "returns nil" do
        expect(FileUpload.file_upload_for(nil, creator_2.id)).to be nil
      end
    end
  end

  describe "#processing?" do
    context "when file_upload state is 'processing'" do
      before do
        file_upload.update(state: FileUpload::STATES[:processing])
      end

      it "returns true" do
        expect(file_upload.processing?).to be true
      end
    end

    context "when file_upload state is not 'processing'" do
      it "returns false" do
        expect(file_upload.processing?).to be false
      end
    end
  end

  describe "#processing" do
    it "updates file_upload state to 'processing'" do
      file_upload.processing

      expect(file_upload.state).to eq FileUpload::STATES[:processing]
    end
  end

  describe "#done?" do
    context "when file_upload state is 'done'" do
      before do
        file_upload.update(state: FileUpload::STATES[:done])
      end

      it "returns true" do
        expect(file_upload.done?).to be true
      end
    end

    context "when file_upload state is not 'done'" do
      it "returns false" do
        expect(file_upload.done?).to be false
      end
    end
  end

  describe "#done" do
    it "updates file_upload state to 'done'" do
      file_upload.done

      expect(file_upload.state).to eq FileUpload::STATES[:done]
    end
  end

  describe "#pending?" do
    context "when file_upload state is 'pending'" do
      it "returns true" do
        expect(file_upload.pending?).to be true
      end
    end

    context "when file_upload state is not 'pending'" do
      before do
        file_upload.update(state: FileUpload::STATES[:processing])
      end

      it "returns false" do
        expect(file_upload.pending?).to be false
      end
    end
  end

  describe "#pending" do
    before do
      file_upload.update(state: FileUpload::STATES[:processing])
    end

    it "updates file_upload state to 'pending'" do
      file_upload.pending

      expect(file_upload.state).to eq FileUpload::STATES[:pending]
    end
  end

  describe "#error?" do
    context "when file_upload state is 'error'" do
      before do
        file_upload.update(state: FileUpload::STATES[:error])
      end

      it "returns true" do
        expect(file_upload.error?).to be true
      end
    end

    context "when file_upload state is not 'error'" do
      it "returns false" do
        expect(file_upload.error?).to be false
      end
    end
  end

  describe "#error" do
    it "updates file_upload state to 'error'" do
      file_upload.error

      expect(file_upload.state).to eq FileUpload::STATES[:error]
    end
  end
end
