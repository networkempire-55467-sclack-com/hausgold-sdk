# frozen_string_literal: true

# Search count details (clever lookup)
Hausgold::User.where(confirmed: true).count

# Query Scopes
Hausgold::User.confirmed
