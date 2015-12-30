require "sinatra/activerecord"
require 'bcrypt'

class User < ActiveRecord::Base
  validates_presence_of :email

  EMAIL_REGEX = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
  has_many :audio_files
  has_many :playlists
  validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
  validates :password, :confirmation => true #password_confirmation attr
  validates_length_of :password, :in => 6..20, :on => :create

  before_save :encrypt_password
  def encrypt_password
      self.password = BCrypt::Password.create(password)
  end

  def authenticate(attempted_password)
    BCrypt::Password.new(self.password) == attempted_password
  end
end
