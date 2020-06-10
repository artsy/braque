require 'spec_helper'

RSpec.describe Braque::Model, type: :model do
  context 'with a custom defined resource name' do
    before do
      class OceanBreeze
        include ::Braque::Model
        api_root_url 'http://localhost:9292'
        remote_resource_name 'Breeze'
        attribute :id
        attribute :title
      end
    end

    let(:root_response) { File.read('spec/fixtures/root.json') }
    let(:breeze_response) { File.read('spec/fixtures/resource.json') }

    let(:root_request) do
      WebMock.stub_request(:get, "#{OceanBreeze.config[:api_root_url]}/")
             .to_return(status: 200, body: root_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:breeze_request) do
      WebMock.stub_request(:get, "#{OceanBreeze.config[:api_root_url]}/breezes/1")
             .to_return(status: 200, body: breeze_response, headers: { 'Content-Type' => 'application/json' })
    end

    let(:ocean_breeze) { OceanBreeze.new id: 1 }

    before do
      root_request
      breeze_request
      @ocean_breeze = OceanBreeze.find(id: 1)
    end

    it 'performs the API root request' do
      expect(root_request).to have_been_requested
    end

    it 'performs the collection request' do
      expect(breeze_request).to have_been_requested
    end
  end
end
