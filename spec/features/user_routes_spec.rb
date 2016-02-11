require 'spec_helper'

def app
  RubyPlay
end

RSpec.describe 'RubyPlay', type: :feature do
  describe 'home page' do
    before { visit 'https://google.com' }
    RubyPlay.class
    it 'displays home page' do
      visit '/'
      expect(page).to have_content 'Ruby Play'
    end

    it '' do
      visit '/'
      expect(page).to have_content 'Ruby Play'
    end


  end
end
