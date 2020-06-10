require 'spec_helper'

RSpec.describe Braque::Collection do
  before(:all) do
    class BraqueClass
      include ::ActiveAttr::Model
      include Braque::Collection
      attribute :id
      attribute :title

      def self.collection_method_name
        name.tableize
      end
    end

    class ResponseLinks
      attr_reader :next
      attr_reader :prev
      def initialize(next_str, previous_str)
        @next = next_str
        @prev = previous_str
      end
    end
  end

  context 'when collection is an array' do
    before(:all) do
      class ResponseCollection < Array
        attr_reader :total_count
        attr_reader :_links
        def initialize(array = [], next_str, previous_str)
          @total_count = 3
          @_links = ResponseLinks.new next_str, previous_str
          super array
        end
      end
    end

    context 'LinkedArray' do
      context '#initialize' do
        before(:all) do
          @array = [{ id: 1, title: 'hello' }, { id: 2, title: 'goodbye' }]
          @response = ResponseCollection.new @array, true, false
          @linked_array = BraqueClass::LinkedArray.new(@response, BraqueClass)
        end

        it 'returns an array of the correct number of items' do
          expect(@linked_array.count).to eq 2
        end

        it 'returns the correct total_count' do
          expect(@linked_array.total_count).to eq 3
        end

        it 'returns an array of new items based on the calling class' do
          expect(@linked_array.first.id).to eq 1
          expect(@linked_array.first.title).to eq @array.first[:title]
          expect(@linked_array.first.class.name).to eq 'BraqueClass'
          expect(@linked_array.last.id).to eq 2
          expect(@linked_array.last.title).to eq @array[1][:title]
          expect(@linked_array.last.class.name).to eq 'BraqueClass'
        end

        it 'responds to previous_link with the correct value' do
          expect(@linked_array).to respond_to(:previous_link)
          expect(@linked_array.previous_link).to eq false
        end

        it 'responds to next_link with the correct value' do
          expect(@linked_array).to respond_to(:next_link)
          expect(@linked_array.next_link).to eq true
        end
      end
    end
  end

  context 'when collection responds to _embedded' do
    before(:all) do
      class ResponseEmbedded
        attr_reader :braque_classes

        def initialize(results)
          @braque_classes = results
        end
      end

      class ResponseCollection < Array
        attr_reader :total_count
        attr_reader :_links
        attr_reader :_embedded

        def initialize(array, next_str, previous_str)
          @total_count = 3
          @_links = ResponseLinks.new next_str, previous_str
          @_embedded = ResponseEmbedded.new array
          super array
        end
      end
    end

    context 'LinkedArray' do
      context '#initialize' do
        before(:all) do
          @array = [{ id: 1, title: 'hello' }, { id: 2, title: 'goodbye' }]
          @response = ResponseCollection.new @array, true, false
          @linked_array = BraqueClass::LinkedArray.new(@response, BraqueClass)
        end

        it 'returns an array of the correct number of items' do
          expect(@linked_array.count).to eq 2
        end

        it 'returns the correct total_count' do
          expect(@linked_array.total_count).to eq 3
        end

        it 'returns an array of new items based on the calling class' do
          expect(@linked_array.first.id).to eq 1
          expect(@linked_array.first.title).to eq @array.first[:title]
          expect(@linked_array.first.class.name).to eq 'BraqueClass'
          expect(@linked_array[1].id).to eq 2
          expect(@linked_array[1].title).to eq @array[1][:title]
          expect(@linked_array[1].class.name).to eq 'BraqueClass'
        end

        it 'responds to previous_link with the correct value' do
          expect(@linked_array).to respond_to(:previous_link)
          expect(@linked_array.previous_link).to eq false
        end

        it 'responds to next_link with the correct value' do
          expect(@linked_array).to respond_to(:next_link)
          expect(@linked_array.next_link).to eq true
        end
      end
    end
  end
end
