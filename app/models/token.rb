class Token < ApplicationRecord
  belongs_to :client, class_name: 'Scim::Client'

  before_create :setup

  def as_json(options = {})
    {
      access_token: access_token,
      token_type: :bearer,
      expires_in: 3600 # NOTE: ignore token expiry and put hard-coded value here for now.
    }
  end

  private

  def setup
    self.access_token = SecureRandom.hex 32
  end
end
