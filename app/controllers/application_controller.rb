class ApplicationController < ActionController::Base
  include Concerns::Authentication

  # protect_from_forgery with: :exception
end
