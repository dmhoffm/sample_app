module ApplicationHelper

  # Return a title on a per-page basis.
  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def gravatar_for(user, options = { :size=>50 })
  	return gravatar_image_tag(user.email.downcase, :alt=>user.name,
  			:class=>'gravatar',
  			:gravatar=>options)
  end
  			
end
