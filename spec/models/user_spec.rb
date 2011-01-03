require 'spec_helper'

describe User do
  
	before(:each) do
		@attr = { 
			:name=>"Example User",
			:email=>"u@e.com",
			:password => "david5",
			:password_confirmation => "david5"
		}
	end
	
	it "should create create a new instance given valid attributes" do
		User.create!(@attr)
	end
	
	it "should require a name" do
		no_name_user = User.new(@attr.merge(:name=>""))
		no_name_user.should_not be_valid
	end
	
	it "should require an email" do
		no_email_user = User.new(@attr.merge(:email=>""))
		no_email_user.should_not be_valid
	end
	
	it "should check for long names" do
		long_name = "a"*51
		long_name_user = User.new(@attr.merge(:name=>long_name))
		long_name_user.should_not be_valid
	end
	
	it "should accept valid email addresses" do
		addresses = %w[d@h.com abc@jjjjj.co.uk bar@goo.org a.x@b.com]
		addresses.each do |address|
			valid_email_user = User.new(@attr.merge(:email=>address))
			valid_email_user.should be_valid
		end
	end
	
	it "should reject invalid email addresses" do
		addresses = %w[d.com a@b@c.com a@b a.com@b] 
		addresses.each do |address| 
			invalid_email_user = User.new(@attr.merge(:email=>address))
			invalid_email_user.should_not be_valid
		end
	end
	
	it "should have a unique email address" do
		User.create!(@attr)
		user_with_duplicate_email = User.new(@attr)
		user_with_duplicate_email.should_not be_valid
	end
	
	it "should have a unique email address being case insensitive" do
		upcased_email = @attr[:email].upcase
		User.create!(@attr)
		user_with_duplicate_email = User.new(@attr.merge(:email=>upcased_email))
		user_with_duplicate_email.should_not be_valid
	end
	
	describe "password validations" do
		
		it "should require a password" do
			no_password_user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
			no_password_user.should_not be_valid
		end
		
		it "should require a matching password confirmation" do
			no_password_confirmation_user = User.new(@attr.merge(:password => "junk"))
			no_password_confirmation_user.should_not be_valid
		end
		
		it "should reject short passwords" do
			short = "a"*5
			short_password_user = User.new(@attr.merge(:password => short, :password_confirmation => short))
			short_password_user.should_not be_valid
		end
		
		it "should reject long passwords" do
			long = "a"*41
			long_password_user = User.new(@attr.merge(:password => long, :password_confirmation => long))
			long_password_user.should_not be_valid
		end
	end
	
	describe "password encryption" do
		
		before(:each) do
			@user = User.create!(@attr)
		end
		
		it "should have an encrypted password attribute" do
			@user.should respond_to(:encrypted_password)
		end
		
		it "should set the encrypted password"  do
			@user.encrypted_password.should_not be_blank
		end
		
		describe "has_password? method" do
			
			it "should be true if the passwords match"  do
				@user.has_password?(@attr[:password]).should be_true
			end
			
			it "should be false if the passwords don't match" do
				@user.has_password?("invalid").should be_false
			end
		end
		
		describe "authenticate method" do
			
			it "should not find non-existing user" do
				wrong_user = User.authenticate("invalid",@attr[:password])
				wrong_user.should be_nil
			end
			
			it "should not find existing user with invalide password" do
				wrong_password = User.authenticate(@attr[:email],"invalid")
				wrong_password.should be_nil
			end
		
			it "should find existing user" do
				valid_user = User.authenticate(@attr[:email],@attr[:password])
				valid_user.should == @user
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
		
		it "should be convertaible to an admin" do
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
		
		it "should respond to the microposts attribute" do
			@user.should respond_to(:microposts)
		end
		
		it "should have the right microposts in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end
		
		it "should destroy associated microposts" do
			@user.destroy
			[@mp1, @mp2].each do |micropost|
				Micropost.find_by_id(micropost.id).should be_nil
			end
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
				mp3 = Factory(:micropost, 
				   :user => Factory(:user, :email => Factory.next(:email)))
				@user.feed.include?(mp3).should_not be_true
			end
		end
	end
		

end
