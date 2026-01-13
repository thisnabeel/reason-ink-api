class ExamplesController < ApplicationController
  before_action :set_example, only: [:show, :update, :destroy]

  # GET /examples
  def index
    @examples = Example.all
    render json: @examples
  end

  # GET /examples/:id
  def show
    render json: @example
  end

  # POST /examples
  def create
    @example = Example.new(example_params)

    if @example.save
      render json: @example, status: :created
    else
      render json: { errors: @example.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /examples/:id
  def update
    if @example.update(example_params)
      render json: @example
    else
      render json: { errors: @example.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /examples/:id
  def destroy
    @example.destroy
    head :no_content
  end

  private

  def set_example
    @example = Example.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Example not found" }, status: :not_found
  end

  def example_params
    params.require(:example).permit(:title, :body, :concept_id)
  end
end

