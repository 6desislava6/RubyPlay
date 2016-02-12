RSpec.describe SiteHelper, :type => :helper do

  def helper
    Class.new { include SiteHelper }.new
  end

  describe "#user_email" do
    context "when the user exists and has an email" do
      it "returns the user's email" do
        user = double("user", :email => "test@test.test")
        expect(helper.user_email(user)).to eq("test@test.test")
      end
    end

    context "when the user exists and has no email" do
      it "returns nil" do
        user = double("user", :email => nil)
        expect(helper.user_email(user)).to eq(nil)
      end
    end

    context "when the user doesn't exist" do
      it "returns nil" do
        expect(helper.user_email(nil)).to eq(nil)
      end
    end
  end

  describe 'displaying audio files' do
    context 'audio files for all audio files and now playing pages' do
      it 'displays two audio files' do
        files = [FactoryGirl.create(:audio_file),
               FactoryGirl.create(:audio_file_second)]
        expect(helper.all_audio_files(files)).to eq '<option>1 Mine</option>' \
        "\n<option>2 Mine 2</option>"
      end

      it 'displays one audio file' do
        files = [FactoryGirl.create(:audio_file)]
        expect(helper.all_audio_files(files)).to eq '<option>1 Mine</option>'
      end

      it 'displays no audio files' do
        files = []
        expect(helper.all_audio_files(files)).to eq ''
      end
    end

    context 'audio files for a playlist' do
      it 'displays two audio files' do
        result = ["<option value = 1 name = \"1\"> 1 Mine </option>",
            "<option value = 2 name = \"2\"> 2 Mine 2 </option>"].join("\n")
        files = [FactoryGirl.create(:audio_file),
               FactoryGirl.create(:audio_file_second)]
        expect(helper.audio_files_make_playlsit(files)).to eq result
      end

      it 'displays one audio file' do
        files = [FactoryGirl.create(:audio_file)]
        expect(helper.audio_files_make_playlsit(files)).to eq "<option" \
        " value = 1 name = \"1\"> 1 Mine </option>"
      end

      it 'displays no audio files' do
        files = []
        expect(helper.audio_files_make_playlsit(files)).to eq ''
      end
    end
  end
end
