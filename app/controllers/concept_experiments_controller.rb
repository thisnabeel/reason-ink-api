class ConceptExperimentsController < ApplicationController
  before_action :set_concept_experiment, only: [:show, :destroy]

  # GET /concept_experiments
  def index
    @concept_experiments = ConceptExperiment.includes(:experiment, :concept).all
    if params[:concept_id]
      @concept_experiments = @concept_experiments.where(concept_id: params[:concept_id])
    end
    render json: @concept_experiments.as_json(include: [:experiment, :concept])
  end

  # GET /concept_experiments/:id
  def show
    render json: @concept_experiment
  end

  # POST /concept_experiments
  def create
    @concept_experiment = ConceptExperiment.new(concept_experiment_params)

    if @concept_experiment.save
      render json: @concept_experiment, status: :created
    else
      render json: { errors: @concept_experiment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /concept_experiments/:id
  def destroy
    @concept_experiment.destroy
    head :no_content
  end

  private

  def set_concept_experiment
    @concept_experiment = ConceptExperiment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "ConceptExperiment not found" }, status: :not_found
  end

  def concept_experiment_params
    params.require(:concept_experiment).permit(:concept_id, :experiment_id)
  end
end
