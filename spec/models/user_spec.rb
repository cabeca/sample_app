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
		@attr = {
			:name => "Example User", 
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
	
	describe "admin attribute" do

		before(:each) do
			@user = User.create!(@attr)
		end

		it "should respond to admin" do
			@user.should respond_to(:admin)
		end

		it "should not be an admin by default" do
			@user.should_not be_admin
		end

		it "should be convertible to an admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end

	describe "micropost associations" do

		before(:each) do
			@user = User.create(@attr)
			@mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
			@mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
		end

		it "should have a microposts attribute" do
			@user.should respond_to(:microposts)
		end

		it "should destroy associated microposts" do
			@user.destroy
			[@mp1, @mp2].each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end
		end

		it "should have the right microposts in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end


		describe "status feed" do

			it "should have a feed" do
				@user.should respond_to(:feed)
			end

			it "should include the user's microposts" do
				@user.feed.include?(@mp1).should be_true
				@user.feed.include?(@mp2).should be_true
			end

			it "should not include a different user's microposts" do
				mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
				@user.feed.include?(mp3).should be_false
			end

			it "should include the microposts of followed users" do
				followed = Factory(:user, :email => Factory.next(:email))
				mp3 = Factory(:micropost, :user => followed)
				@user.follow!(followed)
				@user.feed.should include(mp3)
			end

		end
	end

	describe "relationships" do

		before(:each) do
			@user = User.create!(@attr)
			@followed = Factory(:user)
		end

		it "should have a relationships method" do
			@user.should respond_to(:relationships)
		end

		it "should have a following method" do
			@user.should respond_to(:following)
		end

		it "should have a following? method" do
			@user.should respond_to(:following?)
		end

		it "should have a follow! method" do
			@user.should respond_to(:follow!)
		end

		it "should follow another user" do
			@user.follow!(@followed)
			@user.should be_following(@followed)
		end

		it "should include the followed user in the following array" do
			@user.follow!(@followed)
			@user.following.should include(@followed)
		end

		it "should have an unfollow! method" do
			@user.should respond_to(:unfollow!)
		end

		it "should unfollow another user" do
			@user.follow!(@followed)
			@user.unfollow!(@followed)
			@user.should_not be_following(@followed)
		end

		it "should have a reverse_relationships method" do
			@user.should respond_to(:reverse_relationships)
		end

		it "should have a followers method" do
			@user.should respond_to(:followers)
		end

		it "should include the follower in the followers array" do
			@user.follow!(@followed)
			@followed.followers.should include(@user)
		end

	end
end
