require 'spec_helper'

RSpec.describe Braque::Model, type: :model do
  context 'with multiple defined Braque::Model classes' do
    before do
      class Wind
        include ::Braque::Model
        api_root_url 'http://localhost:9292'
        http_authorization_header 'replace-me'
      end

      class Tide
        include ::Braque::Model
        api_root_url 'http://localhost:9393'
        http_authorization_header 'do-replace-me-as-well'
      end
    end

    it 'sets the correct api_root and http_authorization_header for each class' do
      expect(Tide.config[:api_root_url]).to eq 'http://localhost:9393'
      expect(Tide.config[:http_authorization_header]).to eq 'do-replace-me-as-well'
      expect(Wind.config[:api_root_url]).to eq 'http://localhost:9292'
      expect(Wind.config[:http_authorization_header]).to eq 'replace-me'
    end
  end
end
