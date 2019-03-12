#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'hausgold'

Hausgold.reset_configuration!
Hausgold.configure do |conf|
  conf.app_name = 'local-alarms-experiment'
  conf.env = :local
  # conf.env = :canary
  conf.request_logging = false
  conf.identity_scheme = :password
  conf.identity_params = { email: 'identity-api@hausgold.de',
                           password: 'Oacbos8otAc=' }
end

alarms = [{ channel: 'email', before_minutes: 10 }]

task = Hausgold::Task.create(
  title: 'test',
  description: 'test',
  location: 'test',
  due_date: 20.minutes.from_now,
  editable: true,
  status: 'open',
  user_id: SecureRandom.uuid,
  alarms: { channel: 'email', before_minutes: 10 }
)

alarms << { channel: 'email', before_minutes: 5 }

task.update(alarms: alarms)

pp task.alarms
