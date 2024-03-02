desc "cleanup database records"

namespace :hophub do
  task :cleanup => :environment do
    Rails.logger = Logger.new(STDOUT)
    ApplicationController.helpers.cleanup
  end
end
