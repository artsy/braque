require 'spec_helper'

RSpec.describe 'Braque::Model attribute definitions', type: :model do
  context 'with multiple defined Braque::Model classes' do
    let(:identifier) { 1234 }
    class Agate
      include ::Braque::Model
    end

    class AbsoluteTime
      include ::Braque::Model
      attribute :id
    end

    class Aftershock
      include ::Braque::Model
      attribute :slug

      def to_param
        slug
      end

      def resource_find_options
        { slug: slug }
      end
    end

    class Amygdule < AbsoluteTime
      attribute :slug

      def to_param
        slug
      end

      def resource_find_options
        { slug: slug }
      end
    end

    class Anticline < AbsoluteTime
      attribute :identity

      def to_param
        identity
      end

      def resource_find_options
        { identity: identity }
      end
    end

    context '.to_param' do
      it 'raises an error unless id is defined or the method overridden' do
        expect { Agate.new.to_param }.to raise_error(
          RuntimeError, 'Please overide to_param or add ID to your model attributes.'
        )
      end

      it 'sets to_param string based on instance.id' do
        expect(AbsoluteTime.new(id: identifier).to_param).to eq identifier.to_s
      end

      it 'sets to_param based the overide' do
        expect(Aftershock.new(slug: identifier).to_param).to eq identifier
      end

      it 'sets to_param based the overide' do
        expect(Amygdule.new(slug: identifier).to_param).to eq identifier
      end

      it 'sets to_param based the overide' do
        expect(Anticline.new(identity: identifier).to_param).to eq identifier
      end
    end

    context '.resource_find_options' do
      it 'raises an error unless id is defined or the method is overridden' do
        expect { Agate.new.resource_find_options }.to raise_error(
          RuntimeError, 'Please overide resource_find_options or add ID to your model attributes.'
        )
      end

      it 'returns a hash with the ID' do
        expect(AbsoluteTime.new(id: identifier).resource_find_options).to eq(id: identifier)
      end

      it 'returns the overide' do
        expect(Aftershock.new(slug: identifier).resource_find_options).to eq(slug: identifier)
      end

      it 'returns the overide' do
        expect(Amygdule.new(slug: identifier).resource_find_options).to eq(slug: identifier)
      end

      it 'returns the overide' do
        expect(Anticline.new(identity: identifier).resource_find_options).to eq(identity: identifier)
      end
    end
  end
end
