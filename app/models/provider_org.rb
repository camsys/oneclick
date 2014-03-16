class ProviderOrg < Organization
  resourcify
  has_many :users
  has_one :provider
  has_many :services, through: :provider
end
