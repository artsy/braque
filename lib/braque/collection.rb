module Braque
  module Collection
    class LinkedArray < Array
      attr_reader :next_link
      attr_reader :previous_link
      attr_reader :total_count

      def initialize(response = [], klass)
        @next_link = response._links.try(:next)
        @previous_link = response._links.try(:prev)
        @total_count = response.try(:total_count)
        super build_retrieved_items(response, klass)
      end

      def build_retrieved_items(response, klass)
        retrieved_items = []
        response_collection(response, klass).each do |item|
          retrieved_items << klass.new(item)
        end
        retrieved_items
      end

      def response_collection(response, klass)
        return response unless response.respond_to? :_embedded
        response._embedded.send klass.collection_method_name
      end
    end
  end
end
