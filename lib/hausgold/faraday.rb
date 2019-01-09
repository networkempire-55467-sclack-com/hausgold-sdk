# frozen_string_literal: true

# Register our custom faraday middlewares
Faraday::Request.register_middleware \
  hgsdk_default_headers: Hausgold::Request::DefaultHeaders
Faraday::Response.register_middleware \
  hgsdk_recursive_open_struct: Hausgold::Response::RecursiveOpenStruct
