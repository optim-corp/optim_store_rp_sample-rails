class Tenants::SessionsController < ApplicationController
  before_action :setup_connect_client
  before_action :require_valid_state, only: :create

  def show
    session[:state] = SecureRandom.hex 8
    redirect_to @connect_client.authorization_uri(
      state: session[:state]
    )
  end

  def create
    if params[:code]
      @connect_client.authorization_code = params[:code]
      token_response = @connect_client.access_token!
      id_token = JSON::JWT.decode token_response.id_token, :skip_verification
      user = @current_tenant.users.find_by(identifier: id_token[:sub])
      if user
        authenticate user
        redirect_to root_url
      else
        redirect_to root_url, flash: {
          error: 'User not found'
        }
      end
    else
      redirect_to root_url, flash: {
        error: params[:error]
      }
    end
  end

  private

  def setup_connect_client
    @current_tenant = Contract.find_by!(identifier: params[:tenant_id])
    @connect_client = OpenIDConnect::Client.new(
      identifier: @current_tenant.connect_client.identifier,
      secret: @current_tenant.connect_client.secret,
      redirect_uri: callback_tenant_session_url(@current_tenant.identifier),
      authorization_endpoint: Rails.application.config.optim_store[:authorization_endpoint],
      token_endpoint: Rails.application.config.optim_store[:token_endpoint]
    )
  end

  def require_valid_state
    unless params[:state] == session.delete(:state)
      redirect_to root_url, flash: {
        error: 'CSRF detected'
      }
    end
  end
end
