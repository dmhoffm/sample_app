require 'spec_helper'

describe User do
  
	before(:each) do
		@attr = { :name=>"Example User", :email=>"u@e.com"}
	end
	
	it "should create crate a new instance given valid attributes" do
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
end
