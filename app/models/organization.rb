class Organization < ActiveRecord::Base

  # attr_accessible :name

  # validates :org_type, presence: true

  def agency?
    self.class == Agency
  end

  def provider?
    self.class == ProviderOrg
  end

end
