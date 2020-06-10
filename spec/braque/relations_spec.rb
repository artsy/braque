require 'spec_helper'

RSpec.describe Braque::Relations, type: :model do
  context 'with multiple defined Braque::Model classes' do
    before do
      class Breeze
        include ::Braque::Model
        api_root_url 'http://localhost:9292'
        has_many :tides
        attribute :id
        attribute :title
      end

      class Tide
        include ::Braque::Model
        api_root_url 'http://localhost:9292'
        belongs_to :breeze
        attribute :id
        attribute :title
      end
    end

    let(:root_response) { File.read('spec/fixtures/root.json') }
    let(:breeze_response) { File.read('spec/fixtures/resource.json') }
    let(:tide_response) { File.read('spec/fixtures/associated_resource.json') }
    let(:tides_response) { File.read('spec/fixtures/associated_collection.json') }

    let(:root_request) do
      WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/")
             .to_return(status: 200, body: root_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:breeze_request) do
      WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes/1")
             .to_return(status: 200, body: breeze_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:tide_request) do
      WebMock.stub_request(:get, "#{Tide.config[:api_root_url]}/tides/1")
             .to_return(status: 200, body: tide_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:tides_request) do
      WebMock.stub_request(:get, "#{Tide.config[:api_root_url]}/tides?account_id=1")
             .to_return(status: 200, body: tides_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:breeze) { Breeze.new id: 1 }
    let(:tide) { Tide.new id: 1 }

    before do
      root_request
      breeze_request
      tide_request
      tides_request
    end

    context 'has_many' do
      it 'defines a dynamic instance method for association' do
        expect(breeze.methods).to include :tides
      end

      it 'returns an array of associated objects' do
        associated = breeze.tides
        expect(associated.total_count).to eq 2
      end

      it 'returns an array of associated objects' do
        associated = breeze.tides.first
        expect(associated.class).to eq Tide
        expect(associated.title).to eq(
          JSON.parse(tides_response)['_embedded']['tides'].first['title']
        )
      end
    end

    context 'belongs_to' do
      it 'defines a dynamic instance method for association' do
        expect(tide.methods).to include :breeze
      end

      it 'returns the correct associated object' do
        associated = tide.breeze
        expect(associated.class).to eq Breeze
        expect(associated.title).to eq JSON.parse(breeze_response)['title']
      end
    end
  end
end
