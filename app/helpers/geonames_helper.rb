require 'rest-client'

module GeonamesHelper
  def get_countries(lang)
    if Rails.env.test?
      return [
        ['Germany', 'DE'],
        ['United States', 'US'],
        ['France', 'FR'],
        ['United Kingdom', 'GB'],
      ]
    end

    cache_key = "geonames_countries_#{lang}"

    countries = Rails.cache.read(cache_key)

    unless countries.present?
      begin
        response = RestClient.get('https://secure.geonames.org/countryInfoJSON', {
          params: {
            username: geonames_username(),
            lang: lang,
          }
        })

        countries = JSON.parse(response.body)['geonames']

        Rails.cache.write(cache_key, countries)
      rescue RestClient::ExceptionWithResponse => e
        Rails.logger.error "GeoNames API error: #{e.response}"
        return []
      rescue JSON::ParserError => e
        Rails.logger.error "JSON parsing error: #{e.message}"
        return []
      end
    end

    countries.sort_by! { |country| country['countryName'] }
    countries.map { |country| [country['countryName'], country['countryCode']] }
  end

  def postal_code_search(postal_code, country_code)
    Rails.logger.info "Searching postal code: #{postal_code} in country: #{country_code}"
    cache_key = "geonames_postal_code_#{country_code}_#{postal_code}"
    cached_result = Rails.cache.read(cache_key)

    return cached_result unless cached_result.nil?

    begin
      Rails.logger.info "Cache miss for postal code search: #{cache_key}"

      response = RestClient.get('https://secure.geonames.org/postalCodeSearchJSON', {
        params: {
          postalcode_startsWith: postal_code,
          country: country_code,
          username: geonames_username()
        }
      })

      data = JSON.parse(response.body)
      pc = data['postalCodes'] || []

      Rails.cache.write(cache_key, pc)

      pc
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "GeoNames API error: #{e.response}"
      nil
    rescue JSON::ParserError => e
      Rails.logger.error "JSON parsing error: #{e.message}"
      nil
    end
  end

  def geonames_username
    ENV.fetch("GEONAMES_USERNAME", "invalid_username")
  end
end
