require 'faraday'

module Fyber
  class Client
    def initialize
      @config = Rails.application.config_for(:fyber).try(:symbolize_keys)

      @conn = Faraday.new(url: 'http://api.fyber.com') do |faraday|
        faraday.request :json
        faraday.response :logger #:json, content_type: /\bjson$/
        faraday.use :instrumentation
        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def get_offers(options = {})
      params = options.merge(@config.except(:api_key))
      sorted_params = params.sort_by { |k, _| k }.map { |k, v| "#{k}=#{v}" }.join('&')
      hashkey = Digest::SHA1.hexdigest "#{sorted_params}&#{@config[:api_key]}"
      query_data = "#{params.to_query}&hashkey=#{hashkey}"

      @conn.get "/feed/v1/offers.json?#{query_data}"
    end
  end
end
