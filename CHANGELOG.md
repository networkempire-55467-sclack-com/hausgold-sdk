### 0.13.0

* Added full featured CRUD support for the `SearchProfile` entity (#28)
* Added an initial client for the Maklerportal API (version 2) with
  support for the remote user entity, locally called `Hausgold::Broker` (#29)
* Added the `Hausgold::Broker` entity with CRUD support (#29)
* Added support for fetching matching properties (`Hausgold::Property`)
  via the search profile (#30)
* Enhanced the search subsystem to allow more flexible configuration (eg.
  client method, additional client method arguments) and added support for a
  generalized sorting. The Grape CRUD adapter makes use of the new sorting
  filters from now on, but not all APIs support it yet.
* Added new attributes to the `SearchProfile` and `Property` entities (#31)
* Implemented the adhoc search profile property search, without persisting
  an actual search profile (#32)

### 0.12.0

* Added the new activation workflow for user accounts which are created
  with an inactive state (#24)
* Added a full featured client for the Verkaeuferportal/Kundenportal API with
  support for the remote user entity, locally called `Hausgold::Customer` (#25)
* Implemented support for application/entity name aliases on Global Ids to
  allow transparent masquerading on entities (eg. Kundenportal API is mapped to
  Verkaeuferportal API (until migrated) and Verkaeuferportal API/User becomes
  `Hausgold::Customer` on the SDK) (#25)
* Added Global Id helpers to all `Hausgold::BaseEnity` children, so we support
  the regular `#to_gid` method on instances and a new, same named helper on
  class level which allows us to build a `URI::GID` instance easily for a named
  entity (eg. `Hausgold::Customer.to_gid('uuid')`)

### 0.11.0

* Added `geo_details` attribute to the `Hausgold::Property`
  entity (#23)

### 0.10.0

* Added `lead_id` and `metadata` attributes to the `Hausgold::Property`
  entity (#18)

### 0.9.0

* Added `Hausgold::Property` entity with CRUD support (#17)

### 0.8.0

* Added the `find` and `delete` actions for DataPointEntity (#16)

### 0.7.0

* Improved the instrumentation and request logging facility (logs are colored
  now to make local development easier and error handling was added to be more
  robust on response issues)

### 0.6.0

* The `bang` parameter was removed from `Hausgold::DataPoint#query` requests
* A new helper method `Hausgold::DataPointsResult#data_points_available?` was
  added to answer a common question about the underlying data source

### 0.5.0

* Added `content_type` and `byte_size` to the Asset entity attributes
* Added support for the PDF API client and the `Hausgold::Pdf` entity
  (generation and download)
* Added the `Hausgold::NotificationToken` entity via the Identity API
  (full CRUD support)
* Added the Analytic API client and the `Hausgold::DataPoint` and
  `Hausgold::DataPointEntity` entities (with partial CRUD support,
  based on the API features)
* Implemented the ability to search for entities, this includes
  ActiveRecord-compatible query chaining, cursors (offset/limit) and
  transparent paging (with optimized page layout planning)

### 0.4.0

* Added support for the Asset API (#3)
* Added the `Hausgold::Asset` entity with CRUD support
* Added support to download Asset files (`Hausgold::Asset.find('..').download`)
* Implemented an initial type-casted attribute system (writers and readers)
  and added it to all entities (booleans, symbols, string inquirers)
* Added an automatic `app_name` configuration guessing which is set by a Rails
  Railtie right before initialization
* Added a configuration (`exclude_local_app_gid_locator`) to toggle the
  exclusion of same named local application and Hausgold GID locators
* Allow `Hausgold.locate` to work with local/remote Global Ids the same way by
  autodetecting the responsible locator

### 0.3.0

* Added the `bare_access_token` attribute to the JWT entity (which can be
  used in size limited contexts like HTTP cookies, not supported on every
  application)

### 0.2.0

* Implemented initial entity callbacks (just `after_initialize` for now)
* Track when the JWT identity was issued (`created_at`)
  and allow to query for expiration (`Hausgold::Jwt#expired?`) in a safe way
* Added a configuration for request logging which is enabled by default now
* Added the possibility to configure the logger instance to use
* Added an automatical and implicit identity renewal when expired
* Implemented a generic instrumentation facility for the SDK
  based on ActiveSupport::Notifications
* Added a request/response logging functionality

### 0.1.0

* Implemented a simple association and dirty attribute mapping and tracking
* Implemented the ActiveRecord persistence API
* Stubbed the ActiveRecord query API
* Implemented a base client API with support for Grape APIs
* Implemented a powerful root namespace API
* Implemented an Identity and Calendar API client
* Added the root entities (Jwt, User, Task, Appointment, Timeframe)
* Added a customized Global Identifier locator
* Implemented strict non-bang and bang variants for all API calls
