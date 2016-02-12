require "paperclip/matchers"

RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

Paperclip::Attachment.default_options[:path] = "#{__dir__}/spec/test_files/:class/:id_partition/:style.:extension"

