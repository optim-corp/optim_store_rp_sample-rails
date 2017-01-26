class TokensController < ApplicationController
  def create
    client = Scim::Client.find_by(identifier: params[:client_id])
    if client.present? && client.authenticate(params[:client_secret])
      token = client.tokens.create!
      render json: token#, status: 201
    else
      head 401
    end
  end
end
