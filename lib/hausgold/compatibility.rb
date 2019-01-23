# frozen_string_literal: true

active_model_version = Gem.loaded_specs['activemodel'].version

# Load some polyfills for ActiveModel 4.2
if Gem::Dependency.new('', '~> 4.2.0').match?('', active_model_version)
  require 'hausgold/compatibility/active_model_4_2'
end
