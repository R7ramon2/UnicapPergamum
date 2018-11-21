# require 'net/http'
# require 'json'
# require 'pry'
# require 'socket'

# url = URI.parse("http://127.0.0.1:2000/") 
# http = Net::HTTP.new( url.host, url.port)
# request = Net::HTTP::Post.new( url.path )
# request.set_form_data({"matricula" => "2015204740", "password" => "196722"})
# response = http.request( request )
# binding.pry

require 'net/http/server'
require 'pp'
require 'pry'
require 'json'

matricula = ""
senha = ""
data = {"matricula" => matricula, "password" => senha}

server = Net::HTTP::Server.run(:port => 8000) do |request,stream|
  pp request

  [200, {'Content-Type' => 'application/json'}, [data.to_json]]
end