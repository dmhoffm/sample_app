# By using the symbole ':user', we get Factory Girl to simulate the User model
Factory.define :user do |user|
  user.name						"david h"
  user.email					"d@h.com"
  user.password					"mypassword"
  user.password_confirmation	"mypassword"
end