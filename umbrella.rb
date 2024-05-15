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


