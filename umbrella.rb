pp "Where are you located?"

user_location = gets.chomp.gsub(" ", "%20")

# pp user_location
puts "Checking the weather at #{user_location}...."

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")

require "http"

response = HTTP.get(maps_url)

raw_response = response.to_s

require "json" 

parsed_response = JSON.parse(raw_response)

results = parsed_response.fetch("results")

first_result = results.at(0)

geo = first_result.fetch("geometry")

loc = geo.fetch("location")


#location = loc.fetch("lat") + loc.fetch("lng")
#pp location
latitude = loc.fetch("lat")
longitude = loc.fetch("lng")

location = "#{latitude}, #{longitude}" 

puts "Your coordinates are #{location}"

pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")


# Assemble the full URL string by adding the first part, the API token, and the last part together
 pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_api_key}/#{location}"


# Place a GET request to the URL
raw_weather_response = HTTP.get(pirate_weather_url)

require "json"

parsed_weather_response = JSON.parse(raw_weather_response)



currently_hash = parsed_weather_response.fetch("currently")

current_temp = currently_hash.fetch("temperature")

puts "It is currently " + current_temp.to_s + " F."

minutely_hash = parsed_weather_response.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")
  
end

hour_hash = parsed_weather_response.fetch("hourly")

hour_data_array = hour_hash.fetch("data")

next_twelve_hours = hour_data_array[1..13]
next_hour = hour_data_array[1...2]

precip_prob_threshold = 0.10

any_precipitation = false

require 'ascii_charts'

next_hour.each do |hour_hash|
  precip_prob = hour_hash.fetch("precipProbability")

  if precip_prob > precip_prob_threshold
    any_precipitation = true

    precip_time = Time.at(hour_hash.fetch("time"))

    seconds_from_now = precip_time - Time.now

    next_hour = seconds_from_now / 60 / 60

    puts "Next hour: there is a #{(precip_prob * 100).round}% chance of #{next_hour_summary.downcase}."
  end
end

# Arrays to store x and y coordinates for the chart
chart_data = []

# Iterate over the next twelve hours
next_twelve_hours.each do |hour_hash|
  precip_prob = hour_hash.fetch("precipProbability")
  precip_time = Time.at(hour_hash.fetch("time"))
  seconds_from_now = precip_time - Time.now
  hours_from_now = seconds_from_now / 60 / 60 
  x = hours_from_now.round
  y = (precip_prob * 100).round
  
  # Append x and y coordinates to the chart data array
  chart_data << [x, y]
end

chart_title = "Hours from now vs Precipitation probability"

ascii_chart = AsciiCharts::Cartesian.new(chart_data, title: chart_title, bar: true).draw

puts ascii_chart


if any_precipitation == true
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end
