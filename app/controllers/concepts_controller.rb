class ConceptsController < ApplicationController
  before_action :set_concept, only: [:show, :update, :destroy]

  # GET /concepts
  def index
    @concepts = Concept.all
    render json: @concepts
  end

  # GET /concepts/:id
  def show
    render json: @concept.as_json(
      include: [
        :abstractions,
        :scripts,
        :child_concepts,
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

