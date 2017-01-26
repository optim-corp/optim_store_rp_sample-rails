class Scim::ClientsController < ApplicationController
  before_action :verify_software_statement

  def create
    register_connect_client!
    render json: @current_contract.create_scim_client, status: 201
  end

  private

  def verify_software_statement
    software_statement = JSON::JWT.decode(
      # NOTE: Store has a bug. Accept "contract_statement" for now. It should be "software_statement" though.
      params[:software_statement] || params[:contract_statement],
      :skip_verification
    )

    # Logging
    Rails.logger.info [
      "Decoded SCIM Client Software Statement JWT Header",
      JSON.pretty_generate(software_statement.header)
    ].join("\n")
    Rails.logger.info [
      "Decoded SCIM Client Software Statement JWT Payload",
      JSON.pretty_generate(software_statement)
    ].join("\n")

    # NOTE:
    #  `software_statement.header[:kid]` is same with `software_statement.kid`
    #  Using this syntax for better readability for non-ruby developers.
    @current_contract = Contract.find_by(identifier: software_statement.header[:kid])
    software_statement.verify! OpenSSL::PKey::RSA.new(@current_contract.their_public_key)

    (
      software_statement[:iss] == Rails.application.config.optim_store[:store_url] &&
      software_statement[:aud] == scim_clients_url &&
      Time.now.to_i.between?(software_statement[:iat], software_statement[:exp])
    ) or raise 'Invalid Software Statement'
  end

  def register_connect_client!
    private_key = OpenSSL::PKey::RSA.new @current_contract.our_private_key
    private_jwk = JSON::JWK.new private_key
    software_statement = JSON::JWT.new(
      iss: contracts_url,
      aud: Rails.application.config.optim_store[:client_registration_endpoint],
      redirect_uris: [
        callback_tenant_session_url(@current_contract.identifier)
      ],
      iat: Time.now,
      exp: 30.seconds.from_now
    ).sign(private_jwk)

    # Logging
    Rails.logger.info [
      "Generated OpenID Connect Client Software Statement JWT Header",
      JSON.pretty_generate(software_statement.header)
    ].join("\n")
    Rails.logger.info [
      "Generated OpenID Connect Client Software Statement JWT Payload",
      JSON.pretty_generate(software_statement)
    ].join("\n")

    response = OpenIDConnect.http_client.post Rails.application.config.optim_store[:client_registration_endpoint], {
      software_statement: software_statement.to_s
    }.to_json, 'Content-Type': 'application/json'
    client = JSON.parse(response.body).with_indifferent_access
    @current_contract.create_connect_client!(
      identifier: client[:client_id],
      secret: client[:client_secret]
    )
  end
end
