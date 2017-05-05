require 'config'
require 'net/http'
require 'uri'
require 'json'

module Integrations
  class Airtable
    def self.request(id: nil, params: nil, air_method: raise, task: nil, log: false, async: true)
      request = ->(air, id, params, air_method, task, log) do
        if params
          params = params.dup
          params.delete(:airtable_id)
        end

        response = case air_method
        when :create
          air.create(params)
        when :update
          air.update(id, params)
        when :delete
          air.delete(id)
        end

        puts format_line(response.body) if log
        params = JSON.parse(response.body)
        if task && response.code.to_i == 200
          task.airtable_id = params['id']
          task.save!
        end
      end

      air = new
      return unless air.config_valid?

      if async
        Process.fork do
          request.call(air, id, params, air_method, task, log)
        end
      else
        request.call(air, id, params, air_method, task, log)
      end
    end

    def initialize
      @config = Config.config['airtable']
    end

    def create(params)
      return unless config_valid?
      request(http_method: :post, body: { fields: params })
    end

    def update(id, params)
      return unless config_valid?
      request(http_method: :patch, body: { fields: params }, id: id)
    end

    def delete(id)
      return unless config_valid?
      request(http_method: :delete, id: id)
    end

    def config_valid?
      @config && @config.key?('api_key') && @config.key?('app_key')
    end

    private

    def request(http_method: :get, body: nil, id: nil)
      url = [request_url, id].compact.join
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = case http_method
      when :get
        Net::HTTP::Get.new(uri.request_uri)
      when :post
        Net::HTTP::Post.new(uri.request_uri)
      when :patch
        Net::HTTP::Patch.new(uri.request_uri)
      when :delete
        Net::HTTP::Delete.new(uri.request_uri)
      end

      request.body = body.to_json if body
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@config['api_key']}"
      http.request(request)
    end

    def request_url
      "https://api.airtable.com/v0/#{@config['app_key']}/Table%201/"
    end
  end
end
