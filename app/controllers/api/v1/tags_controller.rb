module Api
  module V1
    class TagsController < ApplicationController
      before_action :set_tag, only: %i[show update destroy]

      # GET /tags
      api :GET, '/v1/tags', 'Retrieve tags.'
      def index
        @tags = Tag.all

        render json: @tags
      end

      def_param_group :tag_id do
        param :id, :number, desc: 'Tag ID', required: true
      end

      # GET /tags/1
      api :GET, '/v1/tags/:id', 'Retrieve a tag based on ID.'
      param_group :tag_id
      def show
        render json: @tag
      end

      def_param_group :tag do
        param :tag, Hash, desc: 'Tag info', required: true do
          param :title, String, desc: 'Tag title', required: true
        end
      end

      # POST /tags
      api :POST, '/v1/tags', 'Create a tag.'
      param_group :tag
      def create
        @tag = Tag.new(tag_params)

        if @tag.save
          render json: @tag, status: :created
        else
          render json: { errors: @tag.errors },
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /tags/1
      api :PATCH, '/v1/tags/:id', 'Update a tag.'
      param_group :tag_id
      param_group :tag
      def update
        if @tag.update(tag_params)
          render json: @tag
        else
          render json: { errors: @tag.errors },
                 status: :unprocessable_entity
        end
      end

      # DELETE /tags/1
      api :DELETE, '/v1/tags/:id', 'Delete a tag.'
      param_group :tag_id
      def destroy
        if @tag.destroy
          render json: {}
        else
          render json: { errors: @tag.errors },
                 status: :unprocessable_entity
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_tag
        @tag = Tag.find_by_id(params[:id])

        return unless @tag.nil?

        render json: { errors: { base: ["Tag ##{params[:id]} not found."] } },
               status: :not_found
      end

      # Only allow a trusted parameter "white list" through.
      def full_tag_params
        params.require(:data)
              .permit(:type, :id, attributes: [:title])
      end

      def tag_params
        full_tag_params[:attributes]
      end
    end
  end
end
