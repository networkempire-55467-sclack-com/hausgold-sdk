# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem includes abstract assets for all kind of entities.
  # An actual asset is a file (eg. images, documents, etc) which can be
  # upload/downloaded. Beside the raw file data an asset bundles also metadata.
  #
  # Users can have appointments, or even properties if you like to.
  class Asset < BaseEntity
    # The low level client
    client :asset_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :title, :description, :public, :attachable,
                 :category, :permissions, :metadata, :file_url,
                 :file, :file_from_url

    # Define attribute types for casting
    typed_attr :public, :boolean, opposite: :private
    typed_attr :category, :string_inquirer

    # Download the asset to a file.
    #
    # @param dest [File, Pathname, nil] the file destination,
    #   a file/IO instance, or when +nil+ we create a temporary file
    # @param args [Hash{Symbol => Mixed}] additional request params
    # @return [File] the downloaded file handle
    def download(dest = nil, **args)
      client.download_asset(self, dest, args)
    end

    # Generate bang method variants
    bangers :download
  end
end
