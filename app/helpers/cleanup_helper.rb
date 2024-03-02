module CleanupHelper
  def cleanup
    r = Event.where("end_date < ?", DateTime.now-1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted outdated event #{event.id} (#{event.name}) with #{event.entries.count} entries"
    end

    r = Entry.where("date < ?", DateTime.now-3.hours).destroy_all
    r.each do |entry|
        Rails.logger.info "Deleted outdated entry #{entry.id} (#{entry.event.name})"
    end

    r = Event.unconfirmed.where("created_at < ?", DateTime.now-1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted unconfirmed event #{event.id} (#{event.name})"
    end

    r = Entry.unconfirmed.where("created_at < ?", DateTime.now-1.day).destroy_all
    r.each do |entry|
        Rails.logger.info "Deleted unconfirmed entry #{entry.id} (#{entry.event.name})"
    end

    AltchaSolution.cleanup
  end
end
