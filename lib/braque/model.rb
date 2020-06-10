module Braque
  module Model
    extend ActiveSupport::Concern
    include ActiveAttr::Model

    included do
      class_attribute :config
      self.config = {}

      # NOTE: Initialize with the Hyperclient resource's _attributes if present.
      # Fallback to permit assigning attributes via a simple hash.
      def initialize(response = nil, options = {})
        attributes = response.respond_to?(:_attributes) ? response._attributes : response
        super(attributes, options)
      end

      # NOTE: This assumes that the related API uses an ID attribute to
      # define the resource. Rails will use this field to construct
      # resource routes in client applications.
      #
      # to_param can be overridden when defining Braque::Model classes
      # in client apps if some other scheme is more advisable.
      #
      def to_param
        raise 'Please overide to_param or add ID to your model attributes.' unless attributes.include? 'id'
        id.to_s
      end

      # NOTE: This assumes that the related API uses an ID field exclusively
      # to locate this resource. resource_find_options is used to build the
      # url path to the API resource
      #
      # resource_find_options can be overridden when defining Braque::Model
      # classes in client apps if some other scheme is more advisable.
      #
      def resource_find_options
        raise 'Please overide resource_find_options or add ID to your model attributes.' unless attributes.include? 'id'
        { id: id }
      end

      def save(params = {})
        response = self.class.client.method(self.class.instance_method_name).call(resource_find_options)
                       ._patch(self.class.instance_method_name.to_s => params)
        self.class.new response
      end

      def destroy
        self.class.client.method(self.class.instance_method_name).call(resource_find_options)._delete
      end

      class_eval <<-WRITER
        def self.#{instance_method_name}
        end

        def self.#{collection_method_name}
        end

        def self.inherited(subclass)
          subclass.class_eval do
            # Allow the config settings for a superclass Braque::Model
            # to be inherited by its subclassed Braque::Model classes
            #
            self.config = self.config.dup

            # Allow a superclass's attributes to be inerited
            # by subclassed Braque::Model classes
            #
            self.attributes = self.superclass.attributes.dup

            define_singleton_method subclass.instance_method_name do
            end

            define_singleton_method subclass.collection_method_name do
            end
          end
        end
      WRITER
    end

    module ClassMethods
      include Braque::Collection
      include Braque::Relations

      [
        :api_root_url,
        :accept_header,
        :authorization_header,
        :http_authorization_header,
        :remote_resource_name
      ].each do |config_option|
        define_method config_option do |value|
          config[config_option] = value
        end
      end

      def list(options = {})
        options = Hash[options.map { |k, v| [CGI.escape(k.to_s), v] }]
        response = client.method(collection_method_name).call(options)
        LinkedArray.new response, self
      end

      def find(options = {})
        response = client.method(instance_method_name).call(options)
        new response
      end

      def create(resource_params = {}, options = {})
        response = client.method(collection_method_name)
                         .call
                         ._post(
                           { instance_method_name.to_s => resource_params }
                            .merge(options)
                         )
        new response
      end

      def collection_method_name
        (config[:remote_resource_name].present? ? config[:remote_resource_name] : name).tableize
      end

      def instance_method_name
        collection_method_name.singularize
      end

      def client
        raise 'Please define api_root for all Braque::Model classes' unless config[:api_root_url]
        Hyperclient.new(config[:api_root_url]) do |client|
          client.headers['Http-Authorization'] = config[:http_authorization_header] if config[:http_authorization_header]
          client.headers['Authorization'] = config[:authorization_header] if config[:authorization_header]
          client.headers['Accept'] = config[:accept_header] if config[:accept_header]
        end
      end
    end
  end
end
