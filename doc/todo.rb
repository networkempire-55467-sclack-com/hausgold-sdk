# frozen_string_literal: true

# Via search, but takes just the first (limit 1)
Hausgold::User.find_by(email: 'test@example.com', confirmed: true)

# Pagination-related / method chaining / lazy evaluation
Hausgold::User.where(confirmed: true).limit(10).offset(5)
Hausgold::User.where(confirmed: true).count
# in batches, until pagination end
Hausgold::User.where(confirmed: true).find_each do |user|
  pp user
end
Hausgold::User.all

# Query Scopes
Hausgold::User.confirmed
