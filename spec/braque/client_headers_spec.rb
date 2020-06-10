require 'spec_helper'

RSpec.describe 'Hyperclient header configuration' do
  let(:root_request) { WebMock.stub_request(:get, 'http://localhost:9292/') }

  before do
    root_request
  end

  context 'with a Braque::Model class that defines an api token' do
    class Mantle
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
      http_authorization_header 'replace-me'
    end

    it 'passes http_authorization_header via Http-Authorization headers with requests' do
      Mantle.client._get
      expect(
        root_request
        .with(headers: { 'Http-Authorization' => Mantle.config[:http_authorization_header] })
      ).to have_been_requested
    end

    it 'passes default Hyperclient Accept headers with requests' do
      Mantle.client._get
      expect(
        root_request
        .with(headers: { 'Accept' => 'application/hal+json,application/json' })
      ).to have_been_requested
    end
  end

  context 'with a Braque::Model class that defines an accept_header' do
    class Subduction
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
      accept_header 'application/vnd.earth-v1+json'
    end

    it 'includes class defined accept_header with request headers' do
      Subduction.client._get
      expect(
        root_request
        .with(headers: { 'Accept' => 'application/vnd.earth-v1+json' })
      ).to have_been_requested
    end
  end

  context 'with a Braque::Model class that defines an authorization header' do
    class Lithoshpere
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
      authorization_header 'Farallon Plate'
    end

    it 'includes correct Authorization header with request headers' do
      Lithoshpere.client._get
      expect(
        root_request
        .with(headers: { 'Authorization' => Lithoshpere.config[:authorization_header] })
      ).to have_been_requested
    end
  end
end
