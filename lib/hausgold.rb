# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_support/cache'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/time'
require 'active_support/time_with_zone'
require 'active_support/string_inquirer'
require 'active_model'
require 'global_id'
require 'recursive-open-struct'
require 'faraday'
require 'faraday_middleware'
require 'http-cookie'
require 'tempfile'
require 'pp'

# Load polyfills if needed
require 'hausgold/compatibility'

# The HAUSGOLD SDK namespace. Everything is bundled here.
module Hausgold
  # Top level elements
  autoload :Configuration, 'hausgold/configuration'
  autoload :ConfigurationHandling, 'hausgold/configuration_handling'
  autoload :Url, 'hausgold/url'
  autoload :Client, 'hausgold/client'
  autoload :Identity, 'hausgold/identity'
  autoload :GlobalId, 'hausgold/global_id'
  autoload :Instrumentation, 'hausgold/instrumentation'
  autoload :ClientCriteria, 'hausgold/client_criteria'

  # Entities
  autoload :BaseEntity, 'hausgold/entity/base_entity'
  autoload :Jwt, 'hausgold/entity/jwt'
  autoload :User, 'hausgold/entity/user'
  autoload :Task, 'hausgold/entity/task'
  autoload :Appointment, 'hausgold/entity/appointment'
  autoload :Timeframe, 'hausgold/entity/timeframe'
  autoload :Asset, 'hausgold/entity/asset'

  # Some general purpose utilities
  module Utils
    autoload :Decision, 'hausgold/utils/decision'
    autoload :Bangers, 'hausgold/utils/bangers'
    autoload :Matchers, 'hausgold/utils/matchers'
  end

  # Faraday request middlewares
  module Request
    autoload :DefaultHeaders, 'hausgold/client/request/default_headers'
  end

  # Faraday response middlewares
  module Response
    autoload :Logger, 'hausgold/client/response/logger'
    autoload :RecursiveOpenStruct,
             'hausgold/client/response/recursive_open_struct'
  end

  # All the client helpers, ready to use
  module ClientUtils
    autoload :Request, 'hausgold/client/utils/request'
    autoload :Response, 'hausgold/client/utils/response'
    autoload :GrapeCrud, 'hausgold/client/utils/grape_crud'
  end

  # All the separated features of the Identity API client
  module IdentityApi
    autoload :Authentication, 'hausgold/client/identity_api/authentication'
    autoload :Users, 'hausgold/client/identity_api/users'
  end

  # All the separated features of the Asset API client
  module AssetApi
    autoload :Downloads, 'hausgold/client/asset_api/downloads'
  end

  # Dedicated application HTTP (low level) clients
  module Client
    autoload :Base, 'hausgold/client/base'
    autoload :AssetApi, 'hausgold/client/asset_api'
    autoload :CalendarApi, 'hausgold/client/calendar_api'
    autoload :IdentityApi, 'hausgold/client/identity_api'
    autoload :Jabber, 'hausgold/client/jabber'
    autoload :MaklerportalApi, 'hausgold/client/maklerportal_api'
    autoload :PdfApi, 'hausgold/client/pdf_api'
    autoload :Preferences, 'hausgold/client/preferences'
    autoload :PropertyApi, 'hausgold/client/property_api'
    autoload :VerkaeuferportalApi, 'hausgold/client/verkaeuferportal_api'
  end

  # Separated features of an entity instance
  module EntityConcern
    autoload :Callbacks, 'hausgold/entity/concern/callbacks'
    autoload :Attributes, 'hausgold/entity/concern/attributes'
    autoload :Associations, 'hausgold/entity/concern/associations'
    autoload :Client, 'hausgold/entity/concern/client'
    autoload :Query, 'hausgold/entity/concern/query'
    autoload :Persistence, 'hausgold/entity/concern/persistence'
  end

  # Load standalone code
  require 'hausgold/version'
  require 'hausgold/errors'
  require 'hausgold/faraday'

  # Include top-level features
  include Hausgold::ConfigurationHandling
  include Hausgold::Url
  include Hausgold::Client
  include Hausgold::Identity
  include Hausgold::GlobalId
  include Hausgold::Instrumentation
end
