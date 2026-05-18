module CleanupHelper
  def cleanup
    r = Event.where("end_date < ?", DateTime.now-1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted outdated event #{event.id} (#{event.name}) with #{event.offers.count} offers"
    end

    r = Offer.where("date < ?", DateTime.now-3.hours).destroy_all
    r.each do |offer|
        Rails.logger.info "Deleted outdated offer #{offer.id} (#{offer.event.name})"
    end

    r = Event.unconfirmed.where("created_at < ?", DateTime.now-1.day).destroy_all
    r.each do |event|
        Rails.logger.info "Deleted unconfirmed event #{event.id} (#{event.name})"
    end

    r = Offer.unconfirmed.where("created_at < ?", DateTime.now-1.day).destroy_all
    r.each do |offer|
        Rails.logger.info "Deleted unconfirmed offer #{offer.id} (#{offer.event.name})"
    end

    r = RideRequest.unconfirmed.where("created_at < ?", DateTime.now-1.day).destroy_all
    r.each do |ride_request|
        Rails.logger.info "Deleted unconfirmed ride request #{ride_request.id} (#{ride_request.event.name})"
    end

    r = RideRequest.where("end_date < ?", DateTime.now).destroy_all
    r.each do |ride_request|
        Rails.logger.info "Deleted outdated ride request #{ride_request.id} (#{ride_request.event.name})"
    end
  end
end
