# frozen_string_literal: true

module Hausgold
  module AssetApi
    # All the downloading functionalities.
    module Downloads
      extend ActiveSupport::Concern

      included do
        # Download the asset to a file.
        #
        # @param asset [Hausgold::Asset] the asset instance to use
        # @param dest [File, Pathname, nil] the file destination,
        #   a file/IO instance, or when +nil+ we create a temporary file
        # @param args [Hash{Symbol => Mixed}] additional request params
        # @return [File] the downloaded file handle
        #
        # rubocop:disable Metrics/AbcSize because thats the bare minimum
        def download_asset(asset, dest = nil, **args)
          # @TODO: Unfortunately Faraday does not support download streaming,
          # at the time of writing. They added a PR and merged it, but it is
          # (?) not yet released.
          #
          # Usage in the future:
          #
          #   req.options.on_data = Proc.new do |chunk, received_bytes|
          #     file.write(chunk)
          #   end
          res = connection.get do |req|
            req.url(asset.file_url)
            use_default_context(req)
            use_jwt_cookie(req) if asset.private?
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(asset, res, id: asset.id))
            result.good { write_to_file(dest) { res.body } }
            successful?(res)
          end
        end
        # rubocop:enable Metrics/AbcSize

        # Generate bang method variants
        bangers :download_asset
      end
    end
  end
end
