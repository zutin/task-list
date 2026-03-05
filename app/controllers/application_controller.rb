class ApplicationController < ActionController::API
  def index = render json: { message: "Welcome to the Task List API" }
end
