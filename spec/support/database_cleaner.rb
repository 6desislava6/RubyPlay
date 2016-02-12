require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

#  config.around(:each) do |example|
#    DatabaseCleaner.cleaning { example.run }
#  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
=begin
FileUtils.cd('./../../public/system/files/1/')
    AudioFile.all.each do |file|
      FileUtils.rm_rf("#{file.file_file_name}")
    end
    FileUtils.cd('./../../../../spec/support')
=end


    DatabaseCleaner.clean

  end
end
