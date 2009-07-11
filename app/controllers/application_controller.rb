# Author:: Renat Akhmerov (mailto:renat@brainhouse.ru)
# Author:: Yury Kotlyarov (mailto:yura@brainhouse.ru)
# License:: MIT License

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'lib/active_record_base'

class ApplicationController < ActionController::Base
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
end
