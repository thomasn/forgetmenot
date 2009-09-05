
require 'forgetmenot/version'

module Forgetmenot
  extend Forgetmenot::Version
  # A string representing the version of Forgetmenot.
  # A more fine-grained representation is available from Forgetmenot.version.
  VERSION = version[:string] unless defined?(Forgetmenot::VERSION)
end

