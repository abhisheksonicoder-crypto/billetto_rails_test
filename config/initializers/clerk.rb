unless Rails.env.test?
  env_file = Rails.root.join(".env")
  if env_file.file?
    env_file.each_line do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#")

      key, value = line.split("=", 2)
      next if key.blank? || value.nil? || ENV[key].present?

      ENV[key] = value.delete_prefix("\"").delete_suffix("\"").delete_prefix("'").delete_suffix("'")
    end
  end
end

if ENV["CLERK_SECRET_KEY"].blank? && !Rails.env.production?
  ENV["CLERK_SECRET_KEY"] = "sk_live_placeholder"
  ENV["CLERK_PUBLISHABLE_KEY"] = "pk_live_placeholder"
end

Clerk.configure do |config|
  config.logger = Rails.logger
end
