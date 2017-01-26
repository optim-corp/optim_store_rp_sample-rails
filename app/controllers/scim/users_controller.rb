class Scim::UsersController < ApplicationController
  before_action :require_access_token

  def index
    user_id = params[:filter].split('and').collect(&:split).detect do |key, operator, value|
      key == 'idtokenClaims.Subject' && operator == 'eq'
    end.last
    users = @current_contract.users.where(identifier: user_id).all
    render json: {
      schemas: ['urn:ietf:params:scim:api:messages:2.0:ListResponse'],
      totalResults: users.count,
      Resources: users.as_json(base_url: scim_users_url)
    }
  end

  def create
    user = @current_contract.users.create!(
      identifier: params[:idtokenclaims][:subject]
    )
    render json: user.as_json(
      base_url: scim_users_url
    ), status: 201
  end

  def update
    user = @current_contract.users.find_by!(
      identifier: params[:idtokenclaims][:subject]
    )
    if params[:active]
      user.activate!
    else
      user.suspend!
    end
    render json: user.as_json(
      base_url: scim_users_url
    )
  end

  def destroy
    user = @current_contract.users.find_by!(
      identifier: params[:idtokenclaims][:subject]
    )
    user.destroy
    head 204
  end

  private

  def require_access_token
    # Logging
    Rails.logger.info [
      "SCIM Provisioning Request JSON",
      JSON.pretty_generate(params.as_json)
    ].join("\n")

    access_token = request.headers['Authorization'].scan(/^Bearer (.*)$/).first.first
    @current_token = Token.find_by(access_token: access_token) or head 401
    @current_contract = @current_token.client.contract
  end
end
