class QuizSetConceptsController < ApplicationController
  before_action :set_quiz_set_concept, only: [:show, :destroy]

  # GET /quiz_set_concepts
  def index
    @quiz_set_concepts = QuizSetConcept.all
    if params[:quiz_set_id]
      @quiz_set_concepts = @quiz_set_concepts.where(quiz_set_id: params[:quiz_set_id])
    end
    render json: @quiz_set_concepts
  end

  # GET /quiz_set_concepts/:id
  def show
    render json: @quiz_set_concept
  end

  # POST /quiz_set_concepts
  def create
    @quiz_set_concept = QuizSetConcept.new(quiz_set_concept_params)

    if @quiz_set_concept.save
      render json: @quiz_set_concept, status: :created
    else
      render json: { errors: @quiz_set_concept.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /quiz_set_concepts/:id
  def destroy
    @quiz_set_concept.destroy
    head :no_content
  end

  private

  def set_quiz_set_concept
    @quiz_set_concept = QuizSetConcept.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "QuizSetConcept not found" }, status: :not_found
  end

  def quiz_set_concept_params
    params.require(:quiz_set_concept).permit(:quiz_set_id, :concept_id)
  end
end

