#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

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
