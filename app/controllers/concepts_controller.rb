class ConceptsController < ApplicationController
  before_action :set_concept, only: [:show, :update, :destroy, :generate_experiment, :generate_phrases]

  # GET /concepts
  def index
    @concepts = Concept.all
    render json: @concepts
  end

  # GET /concepts/timeline
  def timeline
    @concepts = Concept.where.not(end_year: nil).order(end_year: :asc)
    render json: @concepts
  end

  # GET /concepts/:id
  def show
    render json: @concept.as_json(
      include: [
        :abstractions,
        :scripts,
        :phrases,
        :child_concepts,
        :experiments,
        {
          quiz_sets: {
            include: {
              quizzes: {
                include: :quiz_choices
              }
            }
          }
        }
      ]
    )
  end

  # POST /concepts
  def create
    @concept = Concept.new(concept_params)

    if @concept.save
      render json: @concept, status: :created
    else
      render json: { errors: @concept.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /concepts/:id
  def update
    if @concept.update(concept_params)
      render json: @concept
    else
      render json: { errors: @concept.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /concepts/:id
  def destroy
    @concept.destroy
    head :no_content
  end

  # POST /concepts/:id/generate_experiment
  def generate_experiment
    begin
      prompt = params[:prompt] || nil
      @experiment = Experiment.generate_for_concept(@concept, prompt)
      
      if @experiment.save
        # Link the experiment to the concept
        @concept_experiment = ConceptExperiment.create(
          concept: @concept,
          experiment: @experiment
        )
        render json: @experiment, status: :created
      else
        render json: { errors: @experiment.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # POST /concepts/:id/generate_phrases
  def generate_phrases
    begin
      prompt = params[:prompt] || "give me some 5 one-liners that show up as modern day trickle downs within laymen for the philsophical concepts of #{@concept.title}"
      @phrases = Phrase.generate_for_concept(@concept, prompt)
      render json: @phrases, status: :created
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_concept
    @concept = Concept.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Concept not found" }, status: :not_found
  end

  def concept_params
    params.require(:concept).permit(:title, :avatar_url, :start_year, :end_year, :concept_type, :concept_id)
  end
end

