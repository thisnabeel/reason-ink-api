class ScriptsController < ApplicationController
  before_action :set_script, only: [:show, :update, :destroy]

  # GET /scripts
  def index
    @scripts = Script.all
    render json: @scripts
  end

  # GET /scripts/:id
  def show
    render json: @script
  end

  # POST /scripts
  def create
    @script = Script.new(script_params)

    if @script.save
      render json: @script, status: :created
    else
      render json: { errors: @script.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /scripts/:id
  def update
    if @script.update(script_params)
      render json: @script
    else
      render json: { errors: @script.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /scripts/:id
  def destroy
    @script.destroy
    head :no_content
  end

  private

  def set_script
    @script = Script.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Script not found" }, status: :not_found
  end

  def script_params
    params.require(:script).permit(:title, :body, :scriptable_type, :scriptable_id, :position)
  end
end
