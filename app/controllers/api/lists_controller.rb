class Api::ListsController < ApplicationController
  def index
    lists = List.includes(:tasks).all
    render json: { lists: lists.as_json(include: :tasks) }
  end
end
