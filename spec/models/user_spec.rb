# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Example User", :email => "user@example.com" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
		no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
	end

  it "should require an email" do
		no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
	end

  it "name should have 50 character max" do
  	long_name = 'a' * 51
		long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
	end
	
	it "should accept valid email addresses" do
		valid_adresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
		valid_adresses.each do |valid_address|
			valid_user = User.new(@attr.merge(:email => valid_address))
			valid_user.should be_valid
		end
	end
	
	it "should not accept invalid email addresses" do
		invalid_adresses = %w[user@foo,com THE_USER_at_foo.bar.org first.last@foo.]
		invalid_adresses.each do |invalid_address|
			invalid_user = User.new(@attr.merge(:email => invalid_address))
			invalid_user.should_not be_valid
		end
	end
	
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate email addresses, case sensitive" do
    User.create!(@attr)
    upcase_email = @attr[:email].upcase
    user_with_upcase_email = User.new(@attr.merge(:email => upcase_email))
    user_with_upcase_email.should_not be_valid
  end

end
