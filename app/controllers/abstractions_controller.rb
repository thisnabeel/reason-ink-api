class AbstractionsController < ApplicationController
  before_action :set_abstraction, only: [:show, :update, :destroy]

  # GET /abstractions
  def index
    @abstractions = Abstraction.all
    render json: @abstractions
  end

  # GET /abstractions/:id
  def show
    render json: @abstraction
  end

  # POST /abstractions
  def create
    @abstraction = Abstraction.new(abstraction_params)

    if @abstraction.save
      render json: @abstraction, status: :created
    else
      render json: { errors: @abstraction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /abstractions/:id
  def update
    if @abstraction.update(abstraction_params)
      render json: @abstraction
    else
      render json: { errors: @abstraction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /abstractions/:id
  def destroy
    @abstraction.destroy
    head :no_content
  end

  private

  def set_abstraction
    @abstraction = Abstraction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Abstraction not found" }, status: :not_found
  end

  def abstraction_params
    params.require(:abstraction).permit(:body, :abstractable_type, :abstractable_id, :position, :article, :preview, :source_url)
  end
end
