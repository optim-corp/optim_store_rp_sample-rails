class Contract < ApplicationRecord
  before_create :generate_key_pair
  has_one :scim_client,    dependent: :destroy, class_name: 'Scim::Client'
  has_one :connect_client, dependent: :destroy, class_name: 'Connect::Client'
  has_many :users,         dependent: :destroy

  private

  def generate_key_pair
    key_pair = OpenSSL::PKey::RSA.generate 2048
    self.our_private_key = key_pair.to_pem
  end
end
