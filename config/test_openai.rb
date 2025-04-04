require 'openai'
require 'dotenv/load'

# Pass the API key as :api_key
puts "OpenAI API Key: #{ENV['OPENAI_API_KEY']}"
client = OpenAI::Client.new(api_key: ENV['OPENAI_API_KEY'])

texts_to_test = [
  "Met at a conference.",
  "Former boss.",
  "Introduced by a mutual friend.",
  "", # Test empty string
  "This is a very long string to test the character limit. It should cause an error if the character limit is properly implemented..."
]

texts_to_test.each do |text|
  begin
    response = client.embeddings(parameters: { model: "text-embedding-3-small", input: [text] })
    embedding = response.dig("data", 0, "embedding")
    puts "Text: #{text}"
    puts "Embedding: #{embedding.inspect}"
  rescue => e
    puts "Error for text '#{text}': #{e.message}"
  end
end
