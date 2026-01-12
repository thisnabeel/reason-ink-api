class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :update, :destroy]

  # GET /experiments
  def index
    @experiments = Experiment.all
    render json: @experiments
  end

  # GET /experiments/:id
  def show
    render json: @experiment
  end

  # POST /experiments
  def create
    @experiment = Experiment.new(experiment_params)

    if @experiment.save
      render json: @experiment, status: :created
    else
      render json: { errors: @experiment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /experiments/:id
  def update
    if @experiment.update(experiment_params)
      render json: @experiment
    else
      render json: { errors: @experiment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /experiments/:id
  def destroy
    @experiment.destroy
    head :no_content
  end

  private

  def set_experiment
    @experiment = Experiment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Experiment not found" }, status: :not_found
  end

  def experiment_params
    params.require(:experiment).permit(:title, :body)
  end
end
