class Example < ApplicationRecord
  belongs_to :concept
  
  validates :title, presence: true

  def self.generate_for_concept(concept, prompt = nil)
    prompt ||= "Generate an example for the concept '#{concept.title}'. The example should be concise and practical, with a maximum of 250 characters. Return json format: {title: \"the title of the example\", body: \"the body content of the example with HTML formatting for paragraphs and emphasis\"}"
    
    res = ChatGpt.send(prompt)
    
    # Check if there's an error in the response
    if res["error"]
      raise StandardError, res["error"]
    end
    
    if res["title"] && res["body"]
      example = Example.create(
        concept: concept,
        title: res["title"],
        body: res["body"]
      )
      return example
    elsif res["answer"]
      # Fallback if JSON parsing fails but we have an answer
      example = Example.create(
        concept: concept,
        title: "Generated Example",
        body: res["answer"]
      )
      return example
    else
      raise StandardError, "Failed to generate example: Invalid response format"
    end
  end
end
