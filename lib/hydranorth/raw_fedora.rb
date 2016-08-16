module Hydranorth
  module RawFedora

    def get(id, subresource = '', additional_arguments = {})
      response = perform :get, to_pair_tree(id) + subresource, additional_arguments

      xml = Nokogiri::XML.parse(response)
      return response.code, xml
    end

    def perform(action, path, arg_hash = {}, request_headers = {})
      request_headers.reverse_merge!({cache_control: :no_cache})
      user = ActiveFedora.config.credentials[:user]
      password = ActiveFedora.config.credentials[:password]
      endpoint = ActiveFedora.config.credentials[:url] + ActiveFedora.config.credentials[:base_path]

      url = endpoint + path + stringify_args(arg_hash)

      RestClient::Request.execute(
        method: action,
        url: url,
        user: user,
        password: password,
        headers: request_headers)
    end

    def to_pair_tree(id)
      "/#{ActiveFedora::Noid.treeify(id).strip}/"
    end

    def stringify_args(arg_hash)
      accumulator = []
      arg_hash.each { |k, v| accumulator << k.to_s + '=' + v.to_s }
      '?' << accumulator.join('&')
    end

    module_function :get, :perform, :to_pair_tree, :stringify_args
  end
end
