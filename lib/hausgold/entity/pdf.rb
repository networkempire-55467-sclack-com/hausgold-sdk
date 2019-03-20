# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem allows users to generate PDF documents directly from
  # a given website (by URL). You can customize the PDF generation as much as
  # you like. The defaults just works good for German documents. The actual PDF
  # generation takes time and is always performed asynchronously. So the client
  # must poll until the document is available or a callback URL can be
  # specified (by +callback_url+) which is called when the generation is done.
  # This is quite handy in HTTP server contexts, otherwise use the polling.
  class Pdf < BaseEntity
    # The low level client
    client :pdf_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :url,
                 :callback_url, :timeout, :delay, :media, :landscape,
                 :header_footer, :background, :scale, :range, :format, :width,
                 :height, :margin, :margin_top, :margin_right, :margin_bottom,
                 :margin_left

    # Define attribute types for casting
    typed_attr :media, :string_inquirer
    typed_attr :landscape, :boolean, opposite: :portrait
    typed_attr :header_footer, :boolean
    typed_attr :background, :boolean
    typed_attr :format, :string_inquirer

    # Download the PDF to a file.
    #
    # @param dest [File, Pathname, nil] the file destination,
    #   a file/IO instance, or when +nil+ we create a temporary file
    # @param args [Hash{Symbol => Mixed}] additional request params
    # @return [File] the downloaded file handle
    def download(dest = nil, **args)
      client.download_pdf(self, dest, args)
    end

    # Generate bang method variants
    bangers :download
  end
end
