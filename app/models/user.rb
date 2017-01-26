class User < ApplicationRecord
  belongs_to :contract

  def activate!
    self.active = true
    save!
  end

  def suspend!
    self.active = false
    save!
  end

  def as_json(options = {})
    {
      schemas: ['urn:x-optim:scim:schemas:extention:cim:1.0:User'],
      id: identifier,
      active: active?,
      meta: {
        resourceType: 'User',
        created: created_at,
        lastModified: updated_at,
        location: File.join(options[:base_url], identifier)
      }
    }
  end
end
