### 0.5.0

* Added `content_type` and `byte_size` to the Asset entity attributes
* Added support for the PDF API client and the `Hausgold::Pdf` entity
  (generation and download)
* Added the `Hausgold::NotificationToken` entity via the Identity API
  (full CRUD support)
* Added the Analytic API client and the `Hausgold::DataPoint` and
  `Hausgold::DataPointEntity` entities (with partial CRUD support,
  based on the API features)

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
