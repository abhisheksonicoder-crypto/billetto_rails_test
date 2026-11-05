class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
  include Authentication
end
