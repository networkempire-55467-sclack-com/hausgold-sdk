![HAUSGOLD SDK](doc/assets/project.svg)

[![Build Status](https://travis-ci.com/hausgold/hausgold-sdk.svg?token=4XcyqxxmkyBSSV3wWRt7&branch=master)](https://travis-ci.com/hausgold/hausgold-sdk)
[![Gem Version](https://badge.fury.io/rb/hausgold-sdk.svg)](https://badge.fury.io/rb/hausgold-sdk)
[![Maintainability](https://api.codeclimate.com/v1/badges/da2292f1669ec814f361/maintainability)](https://codeclimate.com/repos/5c10e400884193028501175a/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/da2292f1669ec814f361/test_coverage)](https://codeclimate.com/repos/5c10e400884193028501175a/test_coverage)
[![API docs](https://img.shields.io/badge/docs-API-blue.svg)](https://www.rubydoc.info/gems/hausgold-sdk)

This project is dedicated to easily connect your application to the HAUSGOLD
ecosystem by providing a clean API for serveral programming languages. The SDK
comes with client libraries to work with all the entities and workflows.

- [Installation](#installation)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Identity](#identity)
  - [Entities](#entities)
    - [Locating entities](#locating-entities)
    - [Working with entities](#working-with-entities)
    - [Searching for entities](#searching-for-entities)
  - [Low-level Clients](#low-level-clients)
- [Development](#development)
- [Contributing](#contributing)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hausgold-sdk'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install hausgold-sdk
```

## Usage

### Configuration

You can configure the HAUSGOLD SDK in serveral ways. The most relevant settings
should be set on an initializer file when used together with Rails. Here comes
a self descriptive example:

```ruby
Hausgold.configure do |conf|
  # Used to identity this client on the user agent header
  conf.app_name = 'test-client'
  # HAUSGOLD environment to use
  conf.env = :production
  # Allow to set the SDK identity credentials
  conf.identity_scheme = :password
  conf.identity_params = { email: 'your-machine-user',
                           password: 'your-secret-password' }
end
```

### Identity

The HAUSGOLD SDK manages a global identity which is used to authenticate all
requests. The identity is fetched once from the configured credentials and then
used from an in-memory cache. You can also perform requests with different
identities if this is required for your usecase. Furthermore we allow to
perform user masquerades for machine user identities, so you can act in the
name of a different user.

```ruby
# Get the current identity
Hausgold.identity
# => <Hausgold::Jwt>

# Set a new identity, by a +Hausgold::Jwt+ instance
Hausgold.identity(jwt)

# Build a new identity with just an access token
Hausgold.identity(access_token: 'jwt.access.token')

# Switch the identity for the runtime of a block and switch back to
# the previous identity afterwards
Hausgold.switch_identity(jwt) do |current_identity, previous_identity|
  # The operations are performed with the given identity
end

# Start a user masquerade for the runtime of a block. This feature requires the
# globally configured identity to be a machine user.  You can pass an actual
# +Hausgold::Jwt+ instance to use, or you can pass the desired user as
# +Hausgold::User+ instance. Furthermore we accept the id/gid/email (user
# UUID/user Global Id) of the user as criteria. For possible batch/low level
# processing we support an access token from a JWT bundle as a string.
Hausgold.as_user('the-desired-user@email.com') do |current, previous|
  # Perform the operations in the name of the desired user,
  # you can also access the identity of the desired user
end
```

### Entities

As of now we ship support for a bunch of common HAUSGOLD ecosystem entities
ready to use. Here comes a list of them:

* [Hausgold::Jwt](lib/hausgold/entity/jwt.rb)
* [Hausgold::User](lib/hausgold/entity/user.rb)
* [Hausgold::Task](lib/hausgold/entity/task.rb)
* [Hausgold::Appointment](lib/hausgold/entity/appointment.rb)
* [Hausgold::Timeframe](lib/hausgold/entity/timeframe.rb)

#### Locating entities

Almost all entitis/responses are identified by a Global Id (GID) which makes it
easy to uniformly locate and fetch them. All entities/responses comes also with
a classic identifier in form of a Universally Unique Identifier (UUID), which
does not embed any context of the owning application. You can make use of both
identifiers to fetch the corresponding entities.

```ruby
# Locate a HAUSGOLD ecosystem entity uniformly by GID
Hausgold.locate('gid://identity-api/User/uuid')
# => <Hausgold::User>

# Fetch an entity via the corresponding entity model, by UUID
Hausgold::User.find('uuid')

# You can also limit the context of an GID to a specific entity model, which
# results in an raise of an +Hausgold::EntityNotFound+ error in case the result
# is not the expected entity. When the result is a kind of the expected
# entity, it is returned.
Hausgold::User.find('gid://calendar-api/Task/uuid')
# => raised <Hausgold::EntityNotFound>
```

#### Working with entities

The entity owning applications allows almost everytime the full set of CRUD
operations. So you can easily create, update or delete entities in a way you're
used to on ActiveRecord models.

```ruby
# Create a new task, ad hoc on class level. The result is an +Hausgold::Task+
# instance, which was already reloaded (id, gid, etc is set).
Hausgold::Task.create(title: 'Buy milk')
# => <Hausgold::Task>

# Create a new task with a previously instantiated entity
task = Hausgold::Task.new(title: 'Walk the dog')
task.save

# Update an attribute directly via identifier
Hausgold::Task.update('uuid|gid', status: :resolved)
# => <Hausgold::Task> with all attributes reloaded

# You can also delete entities by instance or class level access
Hausgold::Task.delete('uuid|gid')
# => <Hausgold::Task> returns the fully reloaded instance with all attributes
# Which is the very same as
task = Hausgold::Task.find('uuid|gid')
task.delete

# All the CRUD operations follow strictly the bang/non-bang mechanic of
# ActiveRecord. So you can be sure that a
Hausgold::Task.new(title: nil).save
# will pass back +false+ instead of raising. All these operations support
# a bang variant, too. In that case you use
Hausgold::Task.new(title: nil).save!
# an +Hausgold::EntityInvalid+ is raised.
# Take a look at the exception message to find out why the creation failed.

# We also implemented the ActiveModel::Dirty API to reflect changes on
# attributes. This is also used on updates to just send over the changes you
# made, not the whole entity. So you can ask for changes and have the very same
# functionality as with working with ActiveRecord models.
task = Hausgold::Task.find('uuid|gid')
task.changed?
# => false
task.title = 'Something new'
task.changed?
# => true
task.changes
# => {"title"=>["Buy milk", "Something new"]}

# You can also reload an instance from the remote application to fetch the
# current attributes. This allows you also to reset attributes to their original
# values, beside the ActiveModel::Dirty functionality.
task = Hausgold::Task.find('uuid|gid')
task.title = 'Something new'
task.reload
task.title
# => 'Buy milk'

# Create a new asset with direct file upload. (Heads up, we just support
# uploading the asset file while creating it) Afterwards you can access the
# file URL via the +file_url+ attribute. (Heads up, the file URL is not stable
# for private assets)
#
# @see http://bit.ly/2UvSoq6 for +UploadIO+ usage
asset_upload = UploadIO.new('/path/to/file.png', 'image/png')
asset = Hausgold::Asset.new(title: 'A great thing',
                            public: true,
                            file: asset_upload)
asset.file_url
# => 'https://asset-api..'

# You can also create new assets for which the file is fetched from a given
# URL. The download is performed by the Asset API while creating the new asset
# instance, not on your local machine.
asset = Hausgold::Asset.new(title: 'A great thing',
                            public: true,
                            file_from_url: 'https://domain.tld/image.png')
asset.file_url
# => 'https://asset-api..'

# Download an asset file to the local disk. Without any argument a temporary
# file is created. Keep in mind a +Tempfile+ object is automatically deleted
# when the Ruby interpreter exits or the object is garbage collected.
Hausgold::Asset.find('uuid|gid').download
# => #<Tempfile:/tmp/asset20190307-21314-5aw7ay>

# Download an asset to a persistent file by providing the destination path.
Hausgold::Asset.find('uuid|gid').download('/your/path')
# => #<File:/your/path>
```

For all the persistence/dirty tracking methods which are available you can
consult [the code](lib/hausgold/entity/concern/persistence.rb) directly, or use
the following Rails docs:

* [ActiveRecord Instance Persistence](http://bit.ly/2W1rjfF)
* [ActiveRecord Class Persistence](http://bit.ly/2ARRFYB)
* [ActiveModel Dirty Tracking](http://bit.ly/2FRpjB4)

#### Searching for entities

This feature is not yet implemented. Stay tuned.

### Low-level Clients

In case you want to deal with the low level HTTP client of an application for
whatever good reason you have, you can directly get an instance by using
`Hausgold.app(:identity_api)` for example. Normally this is not needed for
regular usage.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hausgold/hausgold-sdk.
