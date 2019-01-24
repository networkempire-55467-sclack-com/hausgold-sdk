# frozen_string_literal: true

module Hausgold
  module Client
    # A base client implementation which eases the pain on higher level client
    # classes.
    class Base
      include ActiveModel::Model

      include Hausgold::ClientUtils::Request
      include Hausgold::ClientUtils::Response
      include Hausgold::Utils::Decision
      include Hausgold::Utils::Bangers

      # Allow the client to be configured
      class_attribute :app_name

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
        con.request :json
        con.request :hgsdk_default_headers
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
      def find_by(*_args)
        raise NotImplementedError.new(self, :find_by)
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

      class << self
        # Initialize the class we were inherited to.
        #
        # @param child_class [Class] the child class which inherits us
        def inherited(child_class)
          child_class.app_name = ''
        end

        # Allow a nice interface for the application name setting.
        #
        # @param name [String] the application name
        def app(name)
          self.app_name = name
        end
      end
    end
  end
end
