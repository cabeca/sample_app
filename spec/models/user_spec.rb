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
    @attr = {	:name => "Example User", 
    					:email => "user@example.com",
    					:password => "foobar",
    					:password_confrmation => "foobar"
    				}
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

	describe "password validations" do

    it "should require a password" do
      user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      user.should_not be_valid
    end

    it "should require a matching password confirmation" do
      user = User.new(@attr.merge(:password_confirmation => "invalid"))
      user.should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      user = User.new(@attr.merge(:password => short, :password_confirmation => short))
      user.should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      user = User.new(@attr.merge(:password => long, :password_confirmation => long))
      user.should_not be_valid
    end
  end
  
  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
    	@user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
    
    	it "should return true if passwords match" do
    		@user.has_password?(@attr[:password]).should be_true
    	end

    	it "should return false if passwords don't match" do
    		@user.has_password?("invalid").should be_false
    	end
    end

    describe "authenticate method" do
    
    	it "should return nil if email doesn't exist" do
    		other_user = User.authenticate("foo@bar.com", @attr[:password])
    		other_user.should be_nil
    	end

    	it "should return nil if email and password don't match" do
    		other_user = User.authenticate(@attr[:email], "invalid")
    		other_user.should be_nil
    	end

    	it "should return the user if email and password match" do
    		other_user = User.authenticate(@attr[:email], @attr[:password])
    		other_user.should == @user
    	end
    end

  end
end
