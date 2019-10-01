# frozen_string_literal: true

module Hausgold
  module Client
    # A base client implementation which eases the pain on higher level client
    # classes.
    class Base
      include ActiveModel::Model

      include Hausgold::ClientUtils::Dsl
      include Hausgold::ClientUtils::Request
      include Hausgold::ClientUtils::Response
      include Hausgold::Utils::Decision
      include Hausgold::Utils::Bangers

      # List of all regular client/CRUD actions
      ACTIONS = %i[find reload search update create delete].freeze

      # Allow the client to be configured
      class_attribute :app_name

      # Allow request/response formats to be configured directly. Direct usage
      # of the writer is not recommended without a client specialization like
      # +Hausgold::ClientUtils::GrapeCrud+.
      class_attribute :action_formats

      # By default we force clients to ensure given identifiers are UUID or
      # Global Id based
      class_attribute :force_uuid_ids

      # Keep track of all entities of a client class
      class_attribute :entities

      # Create a new client instance with the charme of mass assigning all
      # options at once.  We support the following options as a base client:
      #
      # * +:app_name+ - the application name reflects the domain to call
      #
      # The actual path can be customized for each request.
      def initialize(**args)
        super(**args)
      end

      # Configure the connection instance in a generic manner. Each client can
      # modify the connection in a specific way, when the application requires
      # special handling. Just overwrite the +configure+ method, and call
      # +super(con)+. Here is a full example:
      #
      #   def configure(con)
      #     super(con)
      #     con.request :url_encoded
      #     con.response :logger
      #     con.adapter Faraday.default_adapter
      #   end
      #
      # @param con [Faraday::Connection] the connection object
      def configure(con)
        con.use :instrumentation

        # The definition order is execution order
        con.request :hgsdk_default_headers
        con.request :json
        con.request :multipart
        con.request :url_encoded

        # The definition order is reverse to the execution order
        con.response :hgsdk_recursive_open_struct
        con.response :dates
        con.response :json, content_type: /\bjson$/
        con.response :follow_redirects

        con.adapter Faraday.default_adapter
      end

      # Create a new Faraday connection on the first shot, and pass the cached
      # connection object on subsequent calls.
      #
      # @return [Faraday::Connection] the connection object
      def connection
        @connection ||= Faraday.new(url: Hausgold.app_url(app_name),
                                    &method(:configure))
      end

      # Locate an entity with the given Global Id.
      #
      # @param gid [GlobalId, String] a Gid object, or a URI
      # @return [Hausgold::BaseEntity] the found entity
      # @raise [Hausgold::EntityNotFound] when not found
      def locate(gid)
        # Convert the given input to a Global Id
        gid = GlobalID.new(gid) unless gid.is_a? GlobalID
        # We follow the convention of finder names (+find_entity_snake!+)
        finder = gid.model_name.underscore.prepend('find_').concat('!').to_sym
        # Raise when the finder is not implemented
        raise NotImplementedError.new(self, finder) unless respond_to? finder

        # Call the finder, with the identifier
        send(finder, gid.model_id)
      end

      # Find a single entity by its identifier.
      def find(*_args)
        raise NotImplementedError.new(self, :find)
      end

      # Find entities by the given criteria.
      def search(*_args)
        raise NotImplementedError.new(self, :search)
      end

      # Update an entity by the given attributes.
      def update(*_args)
        raise NotImplementedError.new(self, :update)
      end

      # Create an entity by the given attributes.
      def create(*_args)
        raise NotImplementedError.new(self, :create)
      end

      # Create an entity by its identifier.
      def delete(*_args)
        raise NotImplementedError.new(self, :delete)
      end

      # A shorthand for the +.format+ class method.
      #
      # @param args [Array<Symbol>] the path to the config
      #   (eg. +:task, :create+)
      # @return [Symbol] the request format
      def format(*args)
        self.class.format(*args)
      end

      class << self
        # Initialize the class we were inherited to.
        #
        # @param child_class [Class] the child class which inherits us
        def inherited(child_class)
          child_class.app_name = ''
          child_class.action_formats = {}
          child_class.force_uuid_ids = true
          child_class.entities = {}
        end

        # Allow a nice interface for the application name setting.
        #
        # @param name [String] the application name
        def app(name)
          self.app_name = name
        end

        # Just a nice looking short cut for the +force_uuid_ids+ class
        # attribute. By default we force clients to ensure given identifiers
        # are UUID or Global Id based, but there are exceptions.
        def disable_forced_uuid_ids
          self.force_uuid_ids = false
        end

        # Fetch the configured action request and response formats.
        #
        # @param args [Array<Symbol>] the path to the config
        #   (eg. +:task, :create+)
        # @return [Symbol] the request formats
        def format(*args)
          (action_formats || {}).dig(*args) || :json
        end

        # Get a hash for all action methods with their respective default
        # request format configurations.
        #
        # @return [Hash{Symbol => Symbol}] the default action format
        def default_formats
          ACTIONS.each_with_object({}) do |method, memo|
            memo[method] = :json
          end
        end
      end
    end
  end
end
