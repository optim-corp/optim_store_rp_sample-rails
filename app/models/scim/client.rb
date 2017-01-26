class Scim::Client < ApplicationRecord
  belongs_to :contract
  has_many :tokens, dependent: :destroy

  before_create :setup

  def authenticate(secret)
    self.secret == secret
  end

  def as_json(options = {})
    {
      client_id: identifier,
      client_secret: secret
    }
  end

  private

  def setup
    self.identifier = SecureRandom.hex 16
    self.secret     = SecureRandom.hex 32
  end
end
