module SpecAuthentication
  def current_user_id
    example = RSpec.current_example
    return example.metadata[:clerk_user_id] if example&.metadata&.key?(:clerk_user_id)

    super
  end
end

ApplicationController.prepend(SpecAuthentication)
