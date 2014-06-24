require 'json'
require 'addressable/uri'
require 'rest_client'
require 'nokogiri'


address, keyword = nil, nil

until address && keyword
  puts "What kind of place are you looking for?"
  keyword = gets.chomp
  puts "please input your starting address"
  puts "Example: 1061 Market Street, San Francisco, CA"
  address = gets.chomp
end


#find latitude/longitude of App Academy
start_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/geocode/json",
:query_values => { 
  :address => address,
  :key => "AIzaSyA9OyBqtuWnhe9z4S_ngo0nczb2d7QmN-k"
}).to_s

start_response = RestClient.get(start_url)
start_location = JSON.parse(start_response) 
start_latitude = start_location["results"][0]["geometry"]["location"]["lat"]
start_longitude = start_location["results"][0]["geometry"]["location"]["lng"]

### find latitude and longitude of closest ice cream shop
destination_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/place/nearbysearch/json",
:query_values => { 
  :location => "#{start_latitude},#{start_longitude}",
  :rankby => "distance",
  :sensor => false,
  :keyword => keyword,
  :language => "en",
  :key => "AIzaSyA9OyBqtuWnhe9z4S_ngo0nczb2d7QmN-k"
}).to_s

destination_response = RestClient.get(destination_url)
destination_list = JSON.parse(destination_response) 
closest = destination_list["results"][0] 
 destination_latitude = closest["geometry"]["location"]["lat"]
 destination_longitude = closest["geometry"]["location"]["lng"]
 destination_name = closest["name"]
  
###get the directions/path from start address to destination

directions_url = Addressable::URI.new(
:scheme => "https",
:host => "maps.googleapis.com",
:path => "maps/api/directions/json",
:query_values => { 
  :origin => "#{start_latitude},#{start_longitude}",
  :destination => "#{destination_latitude},#{destination_longitude}",
  :language => "en",
  :key => "AIzaSyA9OyBqtuWnhe9z4S_ngo0nczb2d7QmN-k"
}).to_s

direction_response = RestClient.get(directions_url)
directions = JSON.parse(direction_response) 
route_info = directions["routes"][0]["legs"][0]
  start_address = "Start address: " + route_info["start_address"]
  end_address = "End address: " + route_info["end_address"]
  destination = "Destination: " + destination_name
  total_time = "Total time: " + route_info["duration"]["text"]
  total_distance = "Total distance: " + route_info["distance"]["text"] + "\n"
  
directions_array = [start_address, end_address, destination, total_time, total_distance]
route_info["steps"].each_with_index do |leg, index|
  distance = leg["distance"]["text"]
  duration = leg["duration"]["text"]
  instructions = leg["html_instructions"]
  
  step = "step #{index+1}: #{instructions}\n\t duration: #{duration}\n\t distance: #{distance}"
  directions_array << step
end
directions_array = directions_array.join("\n")
parsed_html = Nokogiri::HTML(directions_array)
puts parsed_html.text