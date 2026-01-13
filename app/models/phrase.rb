class Phrase < ApplicationRecord
  belongs_to :concept
  
  validates :body, presence: true

  def self.generate_for_concept(concept, prompt)
    # Ensure prompt requests JSON format with explanation
    json_prompt = "#{prompt}. Return json format: {phrases: [{body: \"phrase text\", explanation: \"why this phrase was chosen\"}, ...]}"
    
    res = ChatGpt.send(json_prompt)
    
    # Check if there's an error in the response
    if res["error"]
      raise StandardError, res["error"]
    end
    
    phrases = []
    
    # Try to parse as array of phrase objects with body and explanation
    if res["phrases"] && res["phrases"].is_a?(Array)
      res["phrases"].each do |phrase_data|
        if phrase_data.is_a?(Hash)
          phrase_body = phrase_data["body"] || phrase_data[:body]
          phrase_explanation = phrase_data["explanation"] || phrase_data[:explanation]
        else
          phrase_body = phrase_data.to_s
          phrase_explanation = nil
        end
        next if phrase_body.blank?
        phrase = Phrase.create(
          concept: concept,
          body: phrase_body.to_s.strip,
          explanation: phrase_explanation&.to_s&.strip
        )
        phrases << phrase if phrase.persisted?
      end
    elsif res.is_a?(Array)
      res.each do |phrase_data|
        if phrase_data.is_a?(Hash)
          phrase_body = phrase_data["body"] || phrase_data[:body]
          phrase_explanation = phrase_data["explanation"] || phrase_data[:explanation]
        else
          phrase_body = phrase_data.to_s
          phrase_explanation = nil
        end
        next if phrase_body.blank?
        phrase = Phrase.create(
          concept: concept,
          body: phrase_body.to_s.strip,
          explanation: phrase_explanation&.to_s&.strip
        )
        phrases << phrase if phrase.persisted?
      end
    elsif res["answer"]
      # If it's a single answer, split by newlines or create one phrase
      lines = res["answer"].split(/\n+/).reject(&:blank?)
      lines.each do |line|
        line = line.gsub(/^\d+[\.\)]\s*/, '').strip # Remove numbering
        next if line.blank?
        phrase = Phrase.create(
          concept: concept,
          body: line
        )
        phrases << phrase if phrase.persisted?
      end
    else
      raise StandardError, "Failed to generate phrases: Invalid response format"
    end
    
    return phrases
  end
end
