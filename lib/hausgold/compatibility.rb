# frozen_string_literal: true

# Check the actual (currently loaded) gem version against the expected
# (given) version. It returns +true+ when the expected version matches the
# actual one. The version check is patch-level independent.
#
# @param expected [String] the expected gem version (eg. +'5.1'+)
# @return [Boolean] whenever the version is loaded or not
def rails_version?(gem_name, expected)
  actual = Gem.loaded_specs[gem_name].version
  Gem::Dependency.new('', "~> #{expected}.0").match?('', actual)
end

# Check the ActiveModel version.
#
# @param expected [String] the expected ActiveModel version (eg. +'5.1'+)
# @return [Boolean] whenever the version is loaded or not
def active_model_version?(expected)
  rails_version? 'activemodel', expected
end

# Check the ActiveSupport version.
#
# @param expected [String] the expected ActiveSupport version (eg. +'5.1'+)
# @return [Boolean] whenever the version is loaded or not
def active_support_version?(expected)
  rails_version? 'activesupport', expected
end

# Load some polyfills for ActiveModel 4.2
require 'hausgold/compatibility/active_model_4_2' \
  if active_model_version? '4.2'

# Load some polyfills for ActiveModel 4.2
require 'hausgold/compatibility/active_support_4_2' \
  if active_support_version? '4.2'

# Load ActiveModel::Type manually on 5.0/5.1
# because it is not in the autoload specs on these versions
if active_model_version?('5.0') || active_model_version?('5.1')
  require 'active_model/type'
end
