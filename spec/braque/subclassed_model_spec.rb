require 'spec_helper'

RSpec.describe Braque::Model, type: :model do
  context 'with subclassed Braque::Model classes' do
    class GeologicModel
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
      http_authorization_header 'replace-me'
      attribute :id
    end

    class ContinentalDrift < GeologicModel
      attribute :name
    end

    class Convection < GeologicModel
      api_root_url 'http://localhost:9595'
      http_authorization_header 'ok-another-one-to-replace'
      attribute :first_name
    end

    class SeafloorSpreading
      include ::Braque::Model
      api_root_url 'http://localhost:9393'
      http_authorization_header 'do-replace-me-as-well'
    end

    context 'api configuration' do
      it 'sets the correct api_root and api_token for the base class' do
        expect(GeologicModel.config[:api_root_url]).to eq 'http://localhost:9292'
        expect(GeologicModel.config[:http_authorization_header]).to eq 'replace-me'
      end
      it 'sets the correct api_root and api_token for a subclassed class' do
        expect(ContinentalDrift.config[:api_root_url]).to eq 'http://localhost:9292'
        expect(ContinentalDrift.config[:http_authorization_header]).to eq 'replace-me'
      end
      it 'sets the correct api_root and api_token for a subclassed class with variable overrides' do
        expect(Convection.config[:api_root_url]).to eq 'http://localhost:9595'
        expect(Convection.config[:http_authorization_header]).to eq 'ok-another-one-to-replace'
      end
      it 'sets the correct api_root and api_token for a new Braque::Model class' do
        expect(SeafloorSpreading.config[:api_root_url]).to eq 'http://localhost:9393'
        expect(SeafloorSpreading.config[:http_authorization_header]).to eq 'do-replace-me-as-well'
      end
    end

    context 'attributes' do
      [GeologicModel, ContinentalDrift, Convection].each do |klass|
        it 'includes attributes defined by the superclass' do
          expect(klass.attributes).to include :id
        end
      end

      it 'includes attributes defined by the subclass' do
        expect(ContinentalDrift.attributes).to include :name
        expect(Convection.attributes).to include :first_name
      end
    end

    context 'dynamic class methods' do
      it 'sets the correct dynamic class methods for the base class' do
        [:geologic_model, :geologic_models].each do |sym|
          expect(GeologicModel.methods).to include(sym)
        end
      end
      it 'sets the correct dynamic class methods for a subclassed class' do
        [:continental_drift, :continental_drifts].each do |sym|
          expect(ContinentalDrift.methods).to include(sym)
        end
      end
      it 'sets the correct dynamic class methods for a subclassed class with variable overrides' do
        [:convection, :convections].each do |sym|
          expect(Convection.methods).to include(sym)
        end
      end
      it 'sets the correct dynamic class methods for a new Braque::Model class' do
        [:seafloor_spreading, :seafloor_spreadings].each do |sym|
          expect(SeafloorSpreading.methods).to include(sym)
        end
      end
    end
  end
end
