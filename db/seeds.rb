require 'faker'

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

3.times do
  event = Event.create(
    id: Faker::Lorem.characters(number: 10),
    name: Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph(sentence_count: 20),
    admin_email: Faker::Internet.email,
    end_date: Faker::Date.between(from: DateTime.now, to: DateTime.now + 1.year),
    confirmed_at: Faker::Date.between(from: DateTime.now-1.month, to: DateTime.now)
  )

  event.save!

  500.times do
    random_coord = random_european_coord

    entry = event.entries.create(
      transport: Entry::TRANSPORTS.sample,
      entry_type: Entry::TYPES.sample,
      direction: Entry::DIRECTIONS.sample,
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone: Faker::PhoneNumber.phone_number,
      date: Faker::Time.between(from: DateTime.now, to: DateTime.now + 1.month),
      location: Faker::Address.full_address,
      latitude: random_coord[0],
      longitude: random_coord[1],
      seats: Faker::Number.between(from: 1, to: 4),
      notes: Faker::Lorem.paragraph(sentence_count: 2),
      confirmed_at: Faker::Date.between(from: DateTime.now-1.month, to: DateTime.now)
    )

    entry.save!
  end
end
