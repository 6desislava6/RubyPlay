require 'spec_helper'

def app
  RubyPlay
end

def current_path
  URI.parse(current_url).path
end

def current_path
  URI.parse(current_url).path
end

RSpec.describe 'RubyPlay', type: :feature do
  describe 'home page' do
    before do
      visit '/'
      @user = FactoryGirl.create(:user)
    end

    it 'displays home page' do
      visit '/'
      expect(page).to have_content 'Ruby Play'
    end

    it 'registers a user' do
      expect do
        within '#sign-up' do
          fill_in 'email', with: 'user@example.com'
          fill_in 'password', with: 'password'
          click_button 'submit'
        end
      end.to change { User.count }.by(1)
    end

    it 'does not register a user with wrong data' do
      wrong_emails = ['u@com', '', 'q23q23q2323', 'aa@.s']
      wrong_emails.each do |email|
        expect do
          within '#sign-up' do
            fill_in 'email', with: email
            fill_in 'password', with: 'password'
            click_button 'submit'
          end
        end.to change { User.count }.by(0)
        visit '/'
      end

      wrong_passwords = ['12345', '1234', '123', '12', '1', '']
      wrong_passwords.each do |password|
        expect do
          within '#sign-up' do
            fill_in 'email', with: 'user@example.com'
            fill_in 'password', with: password
            click_button 'submit'
          end
        end.to change { User.count }.by(0)
        visit '/'
      end
    end

    it 'redirects to now_playing when user is logged' do
      login_as(@user)
      visit '/'
      expect(current_path).to eq("/now_playing")
    end

    it 'logins a user' do
      page.driver.post('/login',
                      { params: { email: "email", password: 'password' } })
      page.status_code.should == 307
    end
  end

  describe 'now_playing page' do

    before do
      @user = FactoryGirl.create(:user)
      login_as(@user)
      visit '/'
    end

    it 'uploads a song and increases number of audiofiles by one' do
      expect do
        within '#upload' do
          path = File.absolute_path('./spec/file_upload/Mine.mp3')
          attach_file('file', path, visible: false)
          click_button 'Upload song'
        end
      end.to change { AudioFile.count }.by(1)
    end

    it 'uploads a song and increases number of user\'s audiofiles by one' do
      expect do
        within '#upload' do
          path = File.absolute_path('./spec/file_upload/Mine.mp3')
          attach_file('file', path, visible: false)
          click_button 'Upload song'
        end
      end.to change { @user.audio_files.count }.by(1)
    end

    it 'changes total size when a file is uploaded' do
      within '#upload' do
        path = File.absolute_path('./spec/file_upload/Mine.mp3')
        attach_file('file', path, visible: false)
        click_button 'Upload song'
      end
      within '#total' do
        expect(page).to have_content('TOTAL : 11 MB')
      end
    end

    it 'does not upload files from wrong format' do
      within '#upload' do
        path = File.absolute_path('./spec/file_upload/Emma-Stone.jpg')
        attach_file('file', path, visible: false)
        click_button 'Upload song'
      end
      p AudioFile.all
      expect(AudioFile.count).to eq(0)
      expect(page).to have_content('{"status":"NOK"}')
    end
  end

end
