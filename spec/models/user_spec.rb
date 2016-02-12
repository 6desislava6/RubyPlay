require 'spec_helper'

describe User do
  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  context 'wrongly created users' do
    it 'does not make a user when email is incorrect' do
      user = User.create(email: '123', password: '123456')
      user.valid?
      user.errors.should have_key(:email)
    end

    it 'does not make a user when password is incorrect' do
      user = User.create(email: 'test@test.test', password: '12346')
      user.valid?
      user.errors.should have_key(:password)
    end

    it 'does not make a user when password and email are incorrect' do
      user = User.create(email: 'test', password: '12346')
      user.valid?
      user.errors.should have_key(:password)
      user.errors.should have_key(:email)
    end
  end

  context 'correctly created users' do
    it 'creates a valid user' do
      user = User.create(email: 'test@test.test', password: '123456')
      expect(user.valid?).to be true
    end
  end

end
