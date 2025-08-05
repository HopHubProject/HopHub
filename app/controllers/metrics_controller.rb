class MetricsController < ApplicationController
  def show
    @timestamp = (Time.now.to_f * 1000).to_i
    render :show, layout: false, content_type: "text/plain, version=0.0.4"
  end
end
