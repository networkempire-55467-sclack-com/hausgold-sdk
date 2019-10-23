#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# rubocop:disable Lint/ShadowingOuterLocalVariable because of the example
# rubocop:disable Lint/Void because of the example

filters = {
  user_id: '96092fa8-707d-4fe6-af5e-4898b9d87a90',
  text: 'Ehrenberg',
  from: 1.month.ago.midnight.iso8601,
  to: 1.month.from_now.midnight.iso8601
}

# Search for a single task
task = Hausgold::Task.find_by(filters.merge(text: 'Task #5'))
task.title
# => "Task #5"

# Check if a task exists with these filters
Hausgold::Task.exists?(filters)
# => true

# Get the first 5 task titles which match the search
Hausgold::Task.where(**filters).map(&:title)
# => ["Task #1", "Task #2", "Task #3", "Task #4", ..]

# Skip the first 50 elements and get the next 50
Hausgold::Task.where(filters).offset(50).limit(50).each do |task|
  task
  # => #<Hausgold::Task ..>
end

# Fetch the search result count
Hausgold::Task.where(filters).count
# => 20

# Raise errors when in-deep client driver expects issues, by default errors are
# swallowed and you may experience empty results instead. There is a
# bang-variant of +#each+ (+#each!+), but while calling Ruby Enumerable methods
# like +#count+, +#first+, +#take+, etc they make use of the non-bang variants
# by default. Calling +#raise!+ on the search criteria beforehand enables the
# bang-variants down to the client driver.
Hausgold::Task.all.count
# => 0
begin
  Hausgold::Task.all.raise!.count
rescue Hausgold::EntitySearchError => e
  e.message
  # => ".. because: user_id, reference_ids are missing,
  #    at least one parameter must be provided"
end
# rubocop:enable Lint/ShadowingOuterLocalVariable
# rubocop:enable Lint/Void
