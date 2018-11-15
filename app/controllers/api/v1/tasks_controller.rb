module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy]

      # GET /tasks
      def index
        @tasks = Task.all.includes(taggings: :tag)

        render json: @tasks
      end

      # GET /tasks/1
      def show
        render json: @task
      end

      # POST /tasks
      def create
        @task = Task.new(task_params)

        if @task.save
          render json: @task, status: :created
        else
          render json: { errors: @task.errors },
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /tasks/1
      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: { errors: @task.errors },
                 status: :unprocessable_entity
        end
      end

      # DELETE /tasks/1
      def destroy
        if @task.destroy
          render json: {}
        else
          render json: { errors: @task.errors },
                 status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_task
        @task = Task.find_by_id(params[:id])

        if @task.nil?
          render json: { errors: "Task ##{params[:id]} not found." },
                 status: :not_found
        end
      end

      # Only allow a trusted parameter "white list" through.
      def full_task_params
        params.require(:data)
              .permit(:type, :id, attributes: [:title, tags: []])
      end

      def task_params
        full_task_params[:attributes]
      end
    end
  end
end
