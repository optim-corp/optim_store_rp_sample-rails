class ContractsController < ApplicationController
  before_action :setup_new_contract, only: :create
  before_action :require_existing_contract, except: :create

  def create
    @contract.save!
    response_json = default_response_claims.merge(
      contract_jwk: JSON::JWK.new(
        OpenSSL::PKey::RSA.new(@contract.our_private_key).public_key
      )
    )
    Rails.logger.info [
      "Contract API Response to OPTiM Store",
      JSON.pretty_generate(response_json)
    ].join("\n")
    render json: response_json, status: 201
  end

  def update
    @contract.update!(
      license_pool: @contract_statement[:license][:pool]
    )
    render json: default_response_claims
  end

  def destroy
    @contract.destroy
    render json: default_response_claims
  end

  private

  def setup_new_contract
    decode_contract_statement
    store_contract_jwks = OpenIDConnect.http_client.get_content(Rails.application.config.optim_store[:contract_jwks_url])
    verify_contract_signature JSON::JWK::Set.new(JSON.parse(store_contract_jwks))
    verify_contract_statement_claims
    @contract = Contract.new(
      identifier: @contract_jwk[:kid],
      license_pool: @contract_statement[:license][:pool],
      their_public_key: @contract_jwk.to_key.to_pem
    )
  end

  def require_existing_contract
    decode_contract_statement
    @contract = Contract.find_by!(identifier: @contract_jwk[:kid])
    verify_contract_signature OpenSSL::PKey::RSA.new(@contract.their_public_key)
    verify_contract_statement_claims
  end

  def decode_contract_statement
    @contract_statement = JSON::JWT.decode(
      params[:contract_statement], :skip_verification
    )

    # Logging
    Rails.logger.info [
      "Decoded Contract Statement JWT Header",
      JSON.pretty_generate(@contract_statement.header)
    ].join("\n")
    Rails.logger.info [
      "Decoded Contract Statement JWT Payload",
      JSON.pretty_generate(@contract_statement)
    ].join("\n")

    @contract_jwk = JSON::JWK.new @contract_statement[:contract_jwk]
    raise 'Invalid Contract Statement' if @contract_jwk[:kid].blank?
  end

  def verify_contract_statement_claims
    (
      @contract_statement[:iss] == Rails.application.config.optim_store[:store_url] &&
      @contract_statement[:aud] == contracts_url &&
      Time.now.to_i.between?(@contract_statement[:iat], @contract_statement[:exp])
    ) or raise 'Invalid Contract Statement'
  end

  def verify_contract_signature(public_key)
    @contract_statement.verify! public_key
  end

  def default_response_claims
    {
      iss: contracts_url,
      aud: Rails.application.config.optim_store[:store_url],
      iat: Time.now.to_i,
      exp: 30.seconds.from_now.to_i
    }
  end
end
