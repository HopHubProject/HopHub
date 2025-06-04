class GeonamesController < ApplicationController
  def postal_code_search
    if params[:postal_code].blank? || params[:country_code].blank?
      render json: { error: 'Postal code and country code are required' }, status: :bad_request
      return
    end

    render json: helpers.postal_code_search(params[:postal_code], params[:country_code])
  end
end
