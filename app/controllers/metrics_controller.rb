class MetricsController < ApplicationController
  def show
    @timestamp = (Time.now.to_f * 1000).to_i

    @events = {
      confirmed: Event.confirmed.count,
      unconfirmed: Event.unconfirmed.count,
    }

    @entries = {
      unconfirmed: Entry.unconfirmed.count,
      offers_way_there: Entry.offer.way_there.confirmed.count,
      requests_way_there: Entry.request.way_there.confirmed.count,
      offers_way_back: Entry.offer.way_back.confirmed.count,
      requests_way_back: Entry.request.way_back.confirmed.count,
    }

    @altcha_solutions = AltchaSolution.count

    render :show, layout: false, content_type: "text/plain, version=0.0.4"
  end
end
