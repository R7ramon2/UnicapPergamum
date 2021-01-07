require 'net/http'
require 'json'
require 'pry'
require 'socket'

url = URI.parse("http://127.0.0.1:8000/") 
http = Net::HTTP.new( url.host, url.port)
request = Net::HTTP::Post.new( url.path )
data = {"matricula" => "", "password" => ""}
request.body = data.to_json
binding.pry
response = http.request( request )
binding.pry
