desc "cleanup database records"

namespace :hophub do
  task :cleanup => :environment do
    Rails.logger = Logger.new(STDOUT)

    r = Event.where("end_date < ?", Time.now+1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted outdated event #{event.id} (#{event.name}) with #{event.entries.count} entries"
    end

    r = Entry.where("date < ?", Time.now-3.hours).destroy_all
    r.each do |entry|
        Rails.logger.info "Deleted outdated entry #{entry.id} (#{entry.event.name})"
    end

    r = Event.unconfirmed.where("created_at < ?", Time.now-1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted unconfirmed event #{event.id} (#{event.name})"
    end

    r = Entry.unconfirmed.where("created_at < ?", Time.now-1.day).destroy_all
    r.each do |entry|
        Rails.logger.info "Deleted unconfirmed entry #{entry.id} (#{entry.event.name})"
    end

    AltchaSolution.cleanup
  end
end
