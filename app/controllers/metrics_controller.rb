class MetricsController < ApplicationController
  def show
    @timestamp = (Time.now.to_f * 1000).to_i

    @events = {
      confirmed: Event.confirmed.count,
      unconfirmed: Event.unconfirmed.count,
    }

    @entries = {
      unconfirmed: Entry.unconfirmed.count,
      offers_way_there: Entry.way_there.confirmed.count,
      offers_way_back: Entry.way_back.confirmed.count,
    }

    @altcha_solutions = AltchaSolution.count

    render :show, layout: false, content_type: "text/plain, version=0.0.4"
  end
end
