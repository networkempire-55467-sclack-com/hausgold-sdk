# frozen_string_literal: true

# Check the actual (currently loaded) ActiveModel version against the expected
# (given) version. It returns +true+ when the expected version matches the
# actual one. The version check is patch-level independent.
#
# @param expected [String] the expected ActiveModel version (eg. +'5.1'+)
# @return [Boolean] whenever the version is loaded or not
def active_model_version?(expected)
  actual = Gem.loaded_specs['activemodel'].version
  Gem::Dependency.new('', "~> #{expected}.0").match?('', actual)
end

# Load some polyfills for ActiveModel 4.2
require 'hausgold/compatibility/active_model_4_2' \
  if active_model_version? '4.2'

# Load ActiveModel::Type manually on 5.0/5.1
# because it is not in the autoload specs on these versions
if active_model_version?('5.0') || active_model_version?('5.1')
  require 'active_model/type'
end
