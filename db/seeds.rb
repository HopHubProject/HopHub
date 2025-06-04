require 'faker'

def place_name_by_coordinates(lat, lng, country_code = 'DE')
  response = RestClient.get('http://api.geonames.org/findNearbyPostalCodesJSON', {
    params: {
      lat: lat,
      lng: lng,
      country: country_code,
      username: ApplicationController.helpers.geonames_username(),
      maxRows: 1
    }
  })

  data = JSON.parse(response.body)
  postal_codes = data['postalCodes'] || []

  postal_codes.first
end

def random_european_coord
  # Define the bounds for Europe
  lat_min = 47.0
  lat_max = 56.0
  lon_min = 5.0
  lon_max = 16.0

  # Generate random latitude and longitude within the bounds
  latitude = lat_min + rand * (lat_max - lat_min)
  longitude = lon_min + rand * (lon_max - lon_min)

  [latitude, longitude]
end

3.times do |i|
  event = Event.create(
    id: Faker::Lorem.characters(number: 10),
    name: Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph(sentence_count: 20),
    admin_email: Faker::Internet.email,
    end_date: Faker::Date.between(from: DateTime.now, to: DateTime.now + 1.year),
    default_country: 'DE',
    confirmed_at: Faker::Date.between(from: DateTime.now-1.month, to: DateTime.now)
  )

  event.save!

  ((i+1)*100).times do
    random_coord = random_european_coord
    pc = place_name_by_coordinates(random_coord[0], random_coord[1])

    next if pc.nil?

    location = "#{pc['postalCode']} #{pc['placeName']}"

    puts "Creating entry for event #{event.name} at coordinates #{random_coord[0]}, #{random_coord[1]} with location '#{location}'"

    entry = event.entries.create(
      transport: Entry::TRANSPORTS.sample,
      direction: Entry::DIRECTIONS.sample,
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.phone_number,
      date: Faker::Time.between(from: DateTime.now, to: DateTime.now + 1.month),
      location: location,
      latitude: random_coord[0],
      longitude: random_coord[1],
      seats: Faker::Number.between(from: 1, to: 4),
      driver: Faker::Boolean.boolean,
      notes: Faker::Lorem.paragraph(sentence_count: 2),
      confirmed_at: Faker::Date.between(from: DateTime.now-1.month, to: DateTime.now)
    )

    entry.save!
  end
end
