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

describe 'RubyPlay', type: :feature do
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

    it 'has the appropriate structure - play, sound, pause' do
      page.should have_css('#play')
      page.should have_css('#sound_up')
      page.should have_css('#sound_down')
    end

    it 'uploads a song and increases number of audiofiles by one' do
      expect do
        within '#upload' do
          path = File.absolute_path('./spec/file_upload/Mine.mp3')
          attach_file('file', path, visible: false)
          click_button 'Upload song'
        end
      end.to change { AudioFile.count }.by(1)
      AudioFile.find(1).file = nil
    end

    it 'uploads a song and increases number of user\'s audiofiles by one' do
      expect do
        within '#upload' do
          path = File.absolute_path('./spec/file_upload/Mine.mp3')
          attach_file('file', path, visible: false)
          click_button 'Upload song'
        end
      end.to change { @user.audio_files.count }.by(1)
      AudioFile.find(1).file = nil

    end

    it 'changes total size when a file is uploaded' do
      within '#upload' do
        path = File.absolute_path('./spec/file_upload/Mine.mp3')
        attach_file('file', path, visible: false)
        click_button 'Upload song'
      end
      within '#total' do
        expect(page).to have_content('TOTAL : 2 MB')
      end
      AudioFile.find(1).file = nil

    end

    it 'does not upload files from wrong format' do
      within '#upload' do
        path = File.absolute_path('./spec/file_upload/Emma-Stone.jpg')
        attach_file('file', path, visible: false)
        click_button 'Upload song'
      end
      expect(AudioFile.count).to eq(0)
      expect(page).to have_content('{"status":"Wrong file format"}')
    end
  end

  describe 'creating playlists and playing them' do
    before do
      @user = FactoryGirl.create(:user)
      login_as(@user)
      visit '/'
    end

    it 'displays no playlists' do
      visit '/playlists'
      expect(page.all 'select#audiofiles option').to be_empty
    end

    it 'makes a playlist' do
      audio_file = FactoryGirl.create(:audio_file)

      visit '/make_playlist'
      find("option[name='1']", text: 'Mine').select_option
      fill_in('name', with: 'test playlist')
      click_button 'makeplaylist'
      expect(Playlist.count).to eq 1
    end

    it 'displays all playlists' do
      audio_file = FactoryGirl.create(:audio_file)

      visit '/make_playlist'
      expect(page).to have_content('Mine')

      find("option[name='1']", text: 'Mine').select_option
      fill_in('name', with: 'test playlist')
      click_button 'makeplaylist'
      expect(Playlist.count).to eq 1
      visit '/playlists'
      page.all('select#audiofiles').map(&:text).should == ['test playlist']
    end

    it 'plays specific playlist' do
      audio_file = FactoryGirl.create(:audio_file)
      audio_file_second = FactoryGirl.create(:audio_file_second)

      visit '/make_playlist'
      find("option[name='1']", text: 'Mine').select_option
      fill_in('name', with: 'test playlist')
      click_button 'makeplaylist'
      visit '/playlists'
      find("option[value='1']", text: 'test playlist').select_option
      click_button 'load'
      page.all('select#audiofiles').map(&:value).should == ['1 Mine']
    end

  end

  describe 'register raspberry' do
    before do
      @user = FactoryGirl.create(:user)
      login_as(@user)
      visit '/register_raspberry'
    end

    it 'has form for raspberry registration if it hasnt been registered yet' do
      ['Host', 'User', 'Password'].each do |field|
        expect(page).to have_content(field)
      end
    end

    it 'can register a raspberry' do
      expect do
        fill_in 'host', with: 'host'
        fill_in 'user', with: 'user'
        fill_in 'password', with: 'password'
        click_button 'registerraspberry'
      end.to change { Raspberry.count }.by (1)
      expect(page).to have_content('You have successfully registered a raspberry device!')
    end

    it 'displays raspberry\'s settings' do
      raspberry = FactoryGirl.create(:raspberry)
      visit '/register_raspberry'
      expect(page).to have_content('host')
    end
  end

  describe 'search bar' do
    before do
      @user = FactoryGirl.create(:user)
      login_as(@user)
      visit '/'
    end

    it 'displays matching songs' do
      audio_file = FactoryGirl.create(:audio_file)
      audio_file_second = FactoryGirl.create(:audio_file_second)
      fill_in 'search', with: 'Mine'
      click_button 'search-ascii'
      page.all('select#audiofiles').map(&:value).should == ['1 Mine']
    end
  end
end
