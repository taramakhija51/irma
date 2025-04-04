require "http"
require "json"

api_key = ENV.fetch("OPENAI_API_KEY")
url = "https://api.openai.com/v1/chat/completions"
response = HTTP.auth("Bearer #{api_key}")
               .post(url, :json => { :model => "gpt-3.5-turbo", :messages => [{ :role => "system", :content => "Hello" }] })

puts response.status
puts response.body.to_s
