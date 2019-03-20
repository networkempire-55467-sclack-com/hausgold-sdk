# frozen_string_literal: true

module Hausgold
  module PdfApi
    # All the downloading functionalities.
    module Downloads
      extend ActiveSupport::Concern

      included do
        # Download the PDF document to a file.
        #
        # @param pdf [Hausgold::Pdf] the pdf instance to use
        # @param dest [File, Pathname, nil] the file destination,
        #   a file/IO instance, or when +nil+ we create a temporary file
        # @param args [Hash{Symbol => Mixed}] additional request params
        # @return [File] the downloaded file handle
        def download_pdf(pdf, dest = nil, **args)
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
            req.url(pdf.url)
            use_default_context(req)
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(pdf, res, id: pdf.id))
            result.good { write_to_file(dest) { res.body } }
            successful?(res)
          end
        end

        # Generate bang method variants
        bangers :download_pdf
      end
    end
  end
end
