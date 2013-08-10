require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
        :first_name => "Example",
        :last_name => "User",
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme"
    }
  end

  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

  end

  describe UserPlace do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should be able to have a UserPlace associated with it" do
      @user.places.create
      @user.places.size.should eq 1
    end
    it "should be able to have multiple UserPlaces associated with it" do
      @user.places.create
      @user.places.create
      @user.places.size.should eq 2
    end
  end

  describe 'buddies' do
    before(:each) do
      @u = FactoryGirl.create(:user)
      @u.buddies.size.should eq 0
      @u.buddy_relationships.size.should eq 0
    end

    it 'should be able to have a buddy requested, and an email should be sent' do
      buddy_email = 'buddy@example.com'
      mock_message = double()
      mock_message.should_receive(:deliver)
      UserMailer.should_receive(:buddy_request_email).with(buddy_email, @u.email).and_return mock_message
      @u.add_buddy buddy_email
      @u.buddies.size.should eq 0
      @u.buddy_relationships.size.should eq 1
      @u.buddy_relationships.pending.size.should eq 1
      @u.buddy_relationships.confirmed.size.should eq 0
      rel = @u.buddy_relationships.first
      rel.should be_pending
      rel.email_address.should eq buddy_email
      @u.should be_pending_buddy(buddy_email)
      @u.should_not be_confirmed_buddy(buddy_email)
    end
    it 'should be able to have a buddy requested, and if buddy exists, pending traveler should appear for the buddy' do
      buddy_email = 'example2@example.com'
      mock_message = double()
      mock_message.should_receive(:deliver)
      UserMailer.should_receive(:buddy_request_email).with("example2@example.com", @u.email).and_return mock_message
      @u2 = FactoryGirl.create(:user2)
      @u2.pending_buddy_requests.size.should eq 0
      @u2.travelers.size.should eq 0

      @u.add_buddy buddy_email
      @u2.pending_buddy_requests.size.should eq 1
      @u2.travelers.size.should eq 0

      @u2.pending_buddy_requests.first.accept
      # @u2.pending_buddy_requests.size.should eq 0
      # @u2.travelers.size.should eq 1

      # @u.buddies.size.should eq 1
      # @u.buddies.first.email.should eq @u2.email
      # @u.should_not be_pending_buddy(buddy_email)
      # @u.should be_confirmed_buddy(buddy_email)
    end
  end
  
  describe 'travelers' do
    
  end
  
end
