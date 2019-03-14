#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require_relative './config'

# Common data
owner = 'gid://identity-api/User/87a5317f-18a4-4fa3-98d3-b97a7076102e'
remote_file_url = 'https://s3-eu-west-1.amazonaws.com/asset-api-test/avatar.jpg'
file_path = File.join(__dir__, '..', '..',
                      'spec', 'fixtures', 'files', 'avatar.jpg')

# Public asset, with direct file upload
asset = Hausgold::Asset.create!(attachable: owner,
                                public: true,
                                file: UploadIO.new(file_path, 'image/jpeg'),
                                title: 'Best avatar ever!')
pp asset.file_url
pp Digest::MD5.hexdigest(asset.download.read) == \
   'f5ca75b99f72f4d35a75e6d4924d8d33'

# Public asset, with direct file upload
asset = Hausgold::Asset.create!(attachable: owner,
                                public: true,
                                file_from_url: remote_file_url,
                                title: 'Best avatar ever!')
pp asset.file_url
pp Digest::MD5.hexdigest(asset.download.read) == \
   'f5ca75b99f72f4d35a75e6d4924d8d33'

# Private asset, with direct file upload
asset = Hausgold::Asset.create!(attachable: owner,
                                public: false,
                                file: UploadIO.new(file_path, 'image/jpeg'),
                                title: 'Best avatar ever!')
pp asset.file_url
pp Digest::MD5.hexdigest(asset.download.read) == \
   'f5ca75b99f72f4d35a75e6d4924d8d33'

# Private asset, with direct file upload
asset = Hausgold::Asset.create!(attachable: owner,
                                public: false,
                                file_from_url: remote_file_url,
                                title: 'Best avatar ever!')
pp asset.file_url
pp Digest::MD5.hexdigest(asset.download.read) == \
   'f5ca75b99f72f4d35a75e6d4924d8d33'
