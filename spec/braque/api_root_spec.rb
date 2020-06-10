require 'spec_helper'

RSpec.describe 'api_root' do
  context 'with a Braque::Model class that does not define api_root' do
    class Rodinia
      include ::Braque::Model
    end

    it 'raises an error' do
      expect { Rodinia.client }.to raise_error(
        RuntimeError, 'Please define api_root for all Braque::Model classes'
      )
    end
  end

  context 'with a Braque::Model class that defines api_root' do
    class Magma
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
    end

    it 'does not raise an error' do
      expect { Magma.client }.to_not raise_error
    end
  end
end
