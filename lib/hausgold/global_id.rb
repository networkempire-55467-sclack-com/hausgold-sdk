# frozen_string_literal: true

# We have to monkey patch the GlobalID gem to allow namespaced model classes.
# The original idea, that the model is 1:1 the same on the remote and local
# application is just not always true. With the new +namespace: Module+ option
# while parsing an Global Id URI you can embed an optional model namespace
# which is evaluated on the +#model_class+ call.
#
# So we stay a) compatible to the regular GlobalID gem API and b) allow the
# local application to work directly with HAUSGOLD ecosystem Global Id URIs
# without the +Hausgold.locate+ helper.
class GlobalID
  # Create a new GlobalID instance. Takes either a GlobalID or a string that
  # can be turned into a GlobalID.
  #
  # @param gid [GlobalID, String] the global id
  # @param options [Hash{Symbol => Mixed}] additional options
  #
  # Options:
  # * **:namespace** - A class or module to use as root namespace for
  #   the model class. This is just used on the +#model_class+ method.
  def initialize(gid, options = {})
    @uri = gid.is_a?(URI::GID) ? gid : URI::GID.parse(gid)
    @model_namespace = options[:namespace]
  end

  # Resolve the global id model class to a usable class object.
  #
  # @return [Class] the model class
  def model_class
    [@model_namespace, model_name].join('::').constantize
  end

  # Some minor improvements of the +GlobalID::Locator+ module.
  module Locator
    # Takes either a GlobalID or a string that can be turned into a GlobalID.
    #
    # @param gid [GlobalID, String] the global id
    # @param options [Hash{Symbol => Mixed}] additional options
    #
    # Options:
    # * **:only** - A class, module or Array of classes and/or modules that are
    #   allowed to be located.  Passing one or more classes limits instances of
    #   returned classes to those classes or their subclasses.  Passing one or
    #   more modules in limits instances of returned classes to those including
    #   that module.  If no classes or modules match, +nil+ is returned.
    def self.locate(gid, options = {})
      return unless (gid = GlobalID.parse(gid, options))

      locator_for(gid).locate gid \
        if find_allowed?(gid.model_class, options[:only])
    end
  end
end

module Hausgold
  # Bundle some helpers for the top level namespace.
  module GlobalId
    extend ActiveSupport::Concern

    included do
      # Fetch the configuration whenever we should exclude the GID locator
      # which may be named like the local app
      exclude_conf = Hausgold.configuration.exclude_local_app_gid_locator
      # Register all configured GID locators
      Hausgold.api_names(exclude_local_app: exclude_conf).each do |app|
        # Register the GID locator for the application
        GlobalID::Locator.use(app, Hausgold.app(app))
      end
    end

    class_methods do
      # Just a simple adapter to the +GlobalID::Locator+.
      #
      # @param gid [GlobalID, String] the Global Id to locate
      # @return [Hausgold::BaseEntity] the resulting entity
      # @raise [Hausgold::EntityNotFound] in case it was not found
      def locate(gid)
        gid = GlobalID.parse(gid, namespace: Hausgold)
        GlobalID::Locator.locate(gid)
      end

      # Build a new Global Id URI string from the given components.
      #
      # @param app [String] the application name
      # @param entity [Class, String] the entity name
      # @param id [String] the entity identifier
      # @return [URI::GID] the assembled Global Id URI
      def build_gid(app, entity, id, **args)
        model = entity.to_s.camelcase
        model = entity.name if entity.is_a? Class
        URI::GID.build(app: app.to_s,
                       model_name: model.remove(/^Hausgold::/),
                       model_id: id.to_s,
                       **args)
      end
    end
  end
end
