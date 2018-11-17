module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy]

      # GET /tasks
      api :GET, '/v1/tasks', 'Retrieve tasks with associated tags.'
      def index
        @tasks = Task.all.includes(taggings: :tag)

        render json: @tasks
      end

      def_param_group :task_id do
        param :id, :number, desc: 'Task ID', required: true
      end

      # GET /tasks/1
      api :GET, '/v1/tasks/:id', 'Retrieve a task based on ID.'
      param_group :task_id
      def show
        render json: @task
      end

      def_param_group :task do
        param :task, Hash, desc: 'Task info', required: true do
          param :title, String, desc: 'Task title', required: true
          param :tags, Array, desc: 'Array of tag strings'
        end
      end

      # POST /tasks
      api :POST, '/v1/tasks', 'Create a task.'
      param_group :task
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
      api :PATCH, '/v1/tasks/:id', 'Update a task.'
      param_group :task_id
      param_group :task
      def update
        if @task.update(task_params)
          render json: @task
        else
          render json: { errors: @task.errors },
                 status: :unprocessable_entity
        end
      end

      # DELETE /tasks/1
      api :DELETE, '/v1/tasks/:id', 'Delete a task.'
      param_group :task_id
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

        return unless @task.nil?

        render json: { errors: { base: ["Task ##{params[:id]} not found."] } },
               status: :not_found
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
