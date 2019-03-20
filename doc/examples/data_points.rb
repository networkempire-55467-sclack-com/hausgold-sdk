#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# rubocop:disable Lint/Void because of the example

id = SecureRandom.uuid
entity = "gid://maklerportal-api/Lead/#{id}"
context = :is24
metric = :visits

# Generate some data points
30.times do |idx|
  Hausgold::DataPoint.create!(
    entity: entity,
    context: context,
    metric: metric,
    value: 1,
    captured_at: idx.days.ago
  )
end

# Update the permissions for this time series
Hausgold::DataPointEntity.create!(
  gid: entity,
  permissions: {
    Hausgold.identity.user.id => 'r',
    SecureRandom.uuid => 'r'
  }
)

# Query the data
result = Hausgold::DataPoint.query!(
  entity: entity,
  context: context,
  metric: metric,
  start_at: 30.days.ago,
  end_at: 1.day.from_now,
  aggregation: :sum,
  interval: :year
)

result
# => <Hausgold::DataPointsResult:0x000055912b1c4348 ..

result.data.first.value
# => "30.0"

result.total_count
# => 1

# rubocop:enable Lint/Void
