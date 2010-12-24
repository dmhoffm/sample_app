# == Schema Information
# Schema version: 20101219040351
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :name, :email, :password, :password_confirmation
	
	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :name, :presence => true, 
	                 :length => {:maximum=>50}
	validates :email, :presence => true,
	                  :format => { :with=>email_regex },
	                  :uniqueness => { :case_sensitive => false }
	validates :password, :presence => true,
					:confirmation => true,
					:length => { :within => 6..40}
					
	before_save :encrypt_password
	
	def has_password?(test_password)
		encrypted_password == encrypt(test_password)
	end
	
	def User.authenticate(email, submitted_password)
		user = User.find_by_email(email)
		return user if user && user.has_password?(submitted_password)
		return nil
	end
	
	private
		def encrypt_password
			self.salt = make_salt if new_record?
			self.encrypted_password = encrypt(password)
		end
		
		def encrypt(string)
			secure_hash("#{salt}--#{string}")
		end
		
		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end
		
		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
	
end