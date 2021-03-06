require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies

    class Trello < OmniAuth::Strategies::OAuth

      option :name, 'trello'

      option :client_options, {
        :access_token_path => "/1/OAuthGetAccessToken",
        :authorize_path => "/1/OAuthAuthorizeToken",
        :request_token_path => "/1/OAuthGetRequestToken",
        :site => "https://trello.com"
      }

      uid do
        user_info['id']
      end

      info do
        {
          :email => raw_info['email'],
          :name  => raw_info['fullName']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/1/members/me').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end

      def user_info
        @user_info ||= raw_info.nil? ? {} : raw_info
      end

      def request_phase
        #options[:authorize_params][:name] = options['app_name']
        options[:authorize_params][:scope] = options['scope'] if options['scope']
        options[:authorize_params][:expiration] = options['expiration'] if options['expiration']
        super
      end
    end
  end
end
