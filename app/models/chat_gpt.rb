require 'openai'

class ChatGpt
  def self.send(prompt)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
    
    puts "The prompt: #{prompt}"
    content = "#{prompt}"

    # Construct a new conversation with only the user message
    messages = [{ role: "user", content: content }]

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o",
          messages: messages,
          temperature: 0.7,
        }
      )
    rescue => e
      puts "OpenAI API Error: #{e.message}"
      return { "error" => "API request failed: #{e.message}" }
    end

    # Check if response has an error
    if response["error"]
      error_message = response.dig("error", "message") || "Unknown API error"
      puts "OpenAI API Error: #{error_message}"
      return { "error" => error_message }
    end

    content_text = response.dig("choices", 0, "message", "content")
    
    if content_text.nil?
      puts "Warning: No content in response"
      puts "Response: #{response.inspect}"
      return { "error" => "No content in API response" }
    end

    content_text = content_text.lstrip

    # Remove markdown code block markers if present
    content_text = content_text.gsub(/^```json\s*/, '').gsub(/^```\s*/, '').gsub(/\s*```$/, '').strip

    begin
      jsonResponse = JSON.parse(content_text)
    rescue JSON::ParserError => e
      puts "JSON parsing failed: #{e.message}"
      puts "Content: #{content_text}"
      jsonResponse = { "answer" => content_text }
    rescue => e
      puts "Error: #{e.message}"
      jsonResponse = { "answer" => content_text }
    end

    return jsonResponse
  end
end

