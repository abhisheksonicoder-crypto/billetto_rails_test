module ApplicationHelper
  def clerk_publishable_key
    ENV["CLERK_PUBLISHABLE_KEY"].to_s
  end

  def clerk_configured?
    key = clerk_publishable_key
    key.start_with?("pk_") && !key.include?("placeholder")
  end
end
