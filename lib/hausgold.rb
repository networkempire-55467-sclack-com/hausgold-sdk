# frozen_string_literal: true

require 'active_support'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_support/cache'
require 'active_support/inflector'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/time'
require 'active_support/time_with_zone'
require 'active_support/string_inquirer'
require 'active_support/subscriber'
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
require 'hausgold/core_ext/hash'

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
  autoload :SearchCriteria, 'hausgold/search_criteria'

  # Search components
  module Search
    autoload :Executor, 'hausgold/search_criteria/executor'
    autoload :Paging, 'hausgold/search_criteria/paging'
    autoload :Settings, 'hausgold/search_criteria/settings'
  end

  # Instrumentation
  module Instrumentation
    autoload :LogSubscriber, 'hausgold/instrumentation/log_subscriber'
  end

  # Entities
  autoload :BaseEntity, 'hausgold/entity/base_entity'
  autoload :Jwt, 'hausgold/entity/jwt'
  autoload :User, 'hausgold/entity/user'
  autoload :Broker, 'hausgold/entity/broker'
  autoload :Customer, 'hausgold/entity/customer'
  autoload :Task, 'hausgold/entity/task'
  autoload :Appointment, 'hausgold/entity/appointment'
  autoload :Timeframe, 'hausgold/entity/timeframe'
  autoload :Asset, 'hausgold/entity/asset'
  autoload :DataPoint, 'hausgold/entity/data_point'
  autoload :DataPointsResult, 'hausgold/entity/data_points_result'
  autoload :DataPointEntity, 'hausgold/entity/data_point_entity'
  autoload :NotificationToken, 'hausgold/entity/notification_token'
  autoload :Pdf, 'hausgold/entity/pdf'
  autoload :Property, 'hausgold/entity/property'
  autoload :SearchProfile, 'hausgold/entity/search_profile'
  autoload :Address, 'hausgold/entity/address'

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
    autoload :Dsl, 'hausgold/client/utils/dsl'
    autoload :Request, 'hausgold/client/utils/request'
    autoload :Response, 'hausgold/client/utils/response'
    autoload :GrapeCrud, 'hausgold/client/utils/grape_crud'
  end

  # All the separated features of the Identity API client
  module IdentityApi
    autoload :Authentication, 'hausgold/client/identity_api/authentication'
    autoload :Users, 'hausgold/client/identity_api/users'
  end

  # All the separated features of the Analytic API client
  module AnalyticApi
    autoload :Query, 'hausgold/client/analytic_api/query'
  end

  # All the separated features of the Asset API client
  module AssetApi
    autoload :Downloads, 'hausgold/client/asset_api/downloads'
  end

  # All the separated features of the Pdf API client
  module PdfApi
    autoload :Downloads, 'hausgold/client/pdf_api/downloads'
  end

  # All the separated features of the Property API client
  module PropertyApi
    autoload :SearchProfiles, 'hausgold/client/property_api/search_profiles'
  end

  # All the separated features of the Verkaeuferportal API client
  module VerkaeuferportalApi
    autoload :Users, 'hausgold/client/verkaeuferportal_api/users'
  end

  # Dedicated application HTTP (low level) clients
  module Client
    autoload :Base, 'hausgold/client/base'
    autoload :AnalyticApi, 'hausgold/client/analytic_api'
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
    autoload :GlobalId, 'hausgold/entity/concern/global_id'
  end

  # Load standalone code
  require 'hausgold/version'
  require 'hausgold/errors'
  require 'hausgold/faraday'
  require 'hausgold/railtie' if defined? Rails

  # Include top-level features
  include Hausgold::ConfigurationHandling
  include Hausgold::Url
  include Hausgold::Client
  include Hausgold::Identity
  include Hausgold::GlobalId
  include Hausgold::Instrumentation
end
