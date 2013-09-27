module OneclickSpecHelpers
  def login_as(user)
    @request.env["devise.mapping"] = Devise.mappings[user]
    mock_user = FactoryGirl.create user
    sign_in mock_user
  end
end

RSpec.configure do |c|
  c.include OneclickSpecHelpers
end
