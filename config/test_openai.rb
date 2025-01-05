require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV['OPENAI_API_KEY']
end

client = OpenAI::Client.new

texts_to_test = [
  "Met at a conference.",
  "Former boss.",
  "Introduced by a mutual friend.",
  "", # Test empty string
  "This is a very long string to test the character limit. It should cause an error if the character limit is properly implemented. this is a very long string to test the character limit. It should cause an error if the character limit is properly implemented. this is a very long string to test the character limit. It should cause an error if the character limit is properly implemented. this is a very long string to test the character limit. It should cause an error if the character limit is properly implemented. this is a very long string to test the character limit. It should cause an error if the character limit is properly implemented. this is a very long string to test the character limit. It should cause an error if the character limit is properly implemented."
]

texts_to_test.each do |text|
  begin
    response = client.embeddings(parameters: { model: 'text-embedding-ada-002', input: text })
    embedding = response.dig("data", 0, "embedding")
    puts "Text: #{text}"
    puts "Embedding: #{embedding.inspect}"
  rescue => e
    puts "Error for text '#{text}': #{e.message}"
  end
end
