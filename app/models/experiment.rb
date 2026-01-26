class Experiment < ApplicationRecord
  has_many :concept_experiments, dependent: :destroy
  has_many :concepts, through: :concept_experiments
  has_many :chat_rooms, as: :chatroomable, dependent: :destroy
  has_many :lobby_entries, as: :chatroomable, dependent: :destroy
  
  validates :title, presence: true

  def self.generate_for_concept(concept, prompt = nil)
    prompt ||= "Generate a thought experiment for one of the philosophies of #{concept.title}. It should be bullet point digestible and minimal sized formatting. Max 300 characters. Return json format: {title: \"the title of the thought experiment\", body: \"the body content of the thought experiment with HTML formatting for paragraphs and emphasis\"}"
    
    res = ChatGpt.send(prompt)
    
    # Check if there's an error in the response
    if res["error"]
      raise StandardError, res["error"]
    end
    
    if res["title"] && res["body"]
      experiment = Experiment.create(
        title: res["title"],
        body: res["body"]
      )
      return experiment
    elsif res["answer"]
      # Fallback if JSON parsing fails but we have an answer
      experiment = Experiment.create(
        title: "Generated Thought Experiment",
        body: res["answer"]
      )
      return experiment
    else
      raise StandardError, "Failed to generate experiment: Invalid response format"
    end
  end
end
