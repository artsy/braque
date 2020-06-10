require 'spec_helper'

RSpec.describe Braque::Model, type: :model do
  before(:all) do
    class Breeze
      include ::Braque::Model
      api_root_url 'http://localhost:9292'
      http_authorization_header 'replace-me'
      accept_header 'application/vnd.el-nino-v1+json'

      attribute :id
      attribute :title
      attribute :token
    end
  end

  let(:root_response) { File.read('spec/fixtures/root.json') }
  let(:root_response_with_token_resource_path) do
    File.read('spec/fixtures/root_with_token_resource_path.json')
  end
  let(:collection_response) { File.read('spec/fixtures/collection.json') }
  let(:parsed_collection_response) { JSON.parse(collection_response) }

  let(:resource_response) { File.read('spec/fixtures/resource.json') }
  let(:parsed_resource_response) { JSON.parse(resource_response) }

  let(:root_request) do
    WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/")
           .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                            'Accept' => Breeze.config[:accept_header] })
           .to_return(status: 200, body: root_response, headers: { 'Content-Type' => 'application/json' })
  end

  let(:root_request_with_token_resource_path) do
    WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/")
           .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                            'Accept' => Breeze.config[:accept_header] })
           .to_return(status: 200, body: root_response_with_token_resource_path,
                      headers: { 'Content-Type' => 'application/json' })
  end

  context 'class methods' do
    it 'responds to find, create, and list' do
      expect(Breeze).to respond_to(:find, :create, :list)
    end

    it 'converts the class name into collection_method_name' do
      expect(Breeze.collection_method_name).to eq 'breezes'
    end

    it 'converts the class name into instance_method_name' do
      expect(Breeze.instance_method_name).to eq 'breeze'
    end

    context '.list' do
      context 'with results' do
        before do
          root_request
          @collection_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes")
                                       .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                        'Accept' => Breeze.config[:accept_header] })
                                       .to_return(status: 200, body: collection_response,
                                                  headers: { 'Content-Type' => 'application/json' })
          @breezes = Breeze.list
        end
        it 'performs the API root request' do
          expect(root_request).to have_been_requested
        end
        it 'performs the collection request' do
          expect(@collection_request).to have_been_requested
        end
        it 'returns an array of items' do
          expect(@breezes.count).to be 2
          expect(@breezes.first).to be_a_kind_of Breeze
          expect(@breezes).to be_a_kind_of Array
        end
        it 'returns items with the correct class' do
          expect(@breezes.first).to be_a_kind_of Breeze
        end
        it 'returns an array of items with the correct attributes' do
          index = 0
          while index < @breezes.size
            breeze = @breezes[index]
            expect(breeze.id).to eq parsed_collection_response['_embedded']['breezes'][index]['id']
            expect(breeze.title).to eq parsed_collection_response['_embedded']['breezes'][index]['title']
            index += 1
          end
        end
      end
      context 'with an errored response' do
        before do
          root_request
          @collection_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes")
                                       .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                        'Accept' => Breeze.config[:accept_header] })
                                       .to_return(status: 500)
        end
        it 'returns a Faraday::ClientError error' do
          expect do
            Breeze.list
          end.to raise_error(Faraday::ClientError, 'the server responded with status 500')
          expect(root_request).to have_been_requested
          expect(@collection_request).to have_been_requested
        end
      end
      context 'with array params' do
        before do
          root_request
          @collection_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes")
                                       .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                        'Accept' => Breeze.config[:accept_header] })
                                       .with(query: 'ids%5B0%5D=1&ids%5B1%5D=2')
                                       .to_return(status: 200, body: collection_response,
                                                  headers: { 'Content-Type' => 'application/json' })
          @breezes = Breeze.list('ids[]' => [1, 2])
        end
        it 'performs the collection request with converted array params' do
          expect(@collection_request).to have_been_requested
        end
      end
    end

    context '.find' do
      context 'under normal conditions' do
        before do
          root_request
          @resource_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes/1")
                                     .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                      'Accept' => Breeze.config[:accept_header] })
                                     .to_return(status: 200, body: resource_response,
                                                headers: { 'Content-Type' => 'application/json' })
          @breeze = Breeze.find(id: 1)
        end
        it 'performs the API root request' do
          expect(root_request).to have_been_requested
        end
        it 'performs the resource request' do
          expect(@resource_request).to have_been_requested
        end
        it 'returns an item with the correct class' do
          expect(@breeze).to be_a_kind_of Breeze
        end
        it 'returns an item with the correct attributes' do
          expect(@breeze.id).to eq parsed_resource_response['id']
          expect(@breeze.title).to eq parsed_resource_response['title']
        end
      end
      context 'with an errored response' do
        before do
          root_request
          @resource_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes/1")
                                     .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                      'Accept' => Breeze.config[:accept_header] })
                                     .to_return(status: 500)
        end
        it 'returns a Faraday::ClientError error' do
          expect do
            @breeze = Breeze.find id: 1
          end.to raise_error(Faraday::ClientError, 'the server responded with status 500')
          expect(root_request).to have_been_requested
          expect(@resource_request).to have_been_requested
        end
      end

      context 'when overriding resource_find_options' do
        before do
          class Breeze
            def resource_find_options
              { id: id, token: token }
            end
          end

          root_request_with_token_resource_path
          @resource_request = WebMock.stub_request(:get, "#{Breeze.config[:api_root_url]}/breezes/1?token=123")
                                     .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                      'Accept' => Breeze.config[:accept_header] })
                                     .to_return(status: 200, body: resource_response,
                                                headers: { 'Content-Type' => 'application/json' })
          @breeze = Breeze.find(id: 1, token: 123)
        end

        it 'performs the API root request' do
          expect(root_request_with_token_resource_path).to have_been_requested
        end
        it 'performs the resource request' do
          expect(@resource_request).to have_been_requested
        end
        it 'returns an item with the correct class' do
          expect(@breeze).to be_a_kind_of Breeze
        end
        it 'returns an item with the correct attributes' do
          expect(@breeze.id).to eq parsed_resource_response['id']
          expect(@breeze.title).to eq parsed_resource_response['title']
        end
      end
    end

    context '.create' do
      context 'with a successful response' do
        context 'without additional options' do
          before do
            root_request
            @create_request = WebMock.stub_request(:post, "#{Breeze.config[:api_root_url]}/breezes")
                                     .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                      'Accept' => Breeze.config[:accept_header] })
                                     .to_return(status: 201, body: resource_response,
                                                headers: { 'Content-Type' => 'application/json' })
            @params = { title: 'What a nice breeze.' }
            @breeze = Breeze.create(@params)
          end
          it 'performs the API root request' do
            expect(root_request).to have_been_requested
          end
          it 'performs the create request' do
            expect(@create_request.with(body: /#{@params.to_json}/)).to have_been_requested
          end
          it 'returns an item with the correct class' do
            expect(@breeze).to be_a_kind_of Breeze
          end
          it 'returns an item with the correct attributes' do
            expect(@breeze.id).to eq parsed_resource_response['id']
            expect(@breeze.title).to eq parsed_resource_response['title']
          end
        end
        context 'with additional options' do
          before do
            root_request
            @params = { title: 'What a nice breeze.' }
            @subdomain = 'breezey'
            @create_request = WebMock.stub_request(:post, "#{Breeze.config[:api_root_url]}/breezes")
                                     .with(headers: {
                                             'Http-Authorization' => Breeze.config[:http_authorization_header],
                                             'Accept' => Breeze.config[:accept_header]
                                           })
                                     .with(body: '{"breeze":{"title":"What a nice breeze."},"subdomain":"breezey"}')
                                     .to_return(status: 201, body: resource_response,
                                                headers: { 'Content-Type' => 'application/json' })
            @breeze = Breeze.create(@params, subdomain: @subdomain)
          end
          it 'performs the API root request' do
            expect(root_request).to have_been_requested
          end
          it 'performs the create request' do
            expect(@create_request).to have_been_requested
          end
          it 'returns an item with the correct class' do
            expect(@breeze).to be_a_kind_of Breeze
          end
          it 'returns an item with the correct attributes' do
            expect(@breeze.id).to eq parsed_resource_response['id']
            expect(@breeze.title).to eq parsed_resource_response['title']
          end
        end
      end
    end
    context 'with an errored response' do
      before do
        root_request
        @create_request = WebMock.stub_request(:post, "#{Breeze.config[:api_root_url]}/breezes")
                                 .with(headers: {
                                         'Http-Authorization' => Breeze.config[:http_authorization_header],
                                         'Accept' => Breeze.config[:accept_header]
                                       }).to_return(status: 500)
      end
      it 'returns a Faraday::ClientError error' do
        expect do
          Breeze.create {}
        end.to raise_error(Faraday::ClientError, 'the server responded with status 500')
        expect(root_request).to have_been_requested
        expect(@create_request).to have_been_requested
      end
    end
  end
  context 'instance methods' do
    it 'sets to_param string based on instance.id' do
      expect(Breeze.new(id: 1).to_param).to eq 1.to_s
    end

    context '#save' do
      context 'under normal conditions' do
        before do
          root_request
          @save_request = WebMock.stub_request(:patch, "#{Breeze.config[:api_root_url]}/breezes/1")
                                 .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                  'Accept' => Breeze.config[:accept_header] })
                                 .to_return(status: 200, body: resource_response,
                                            headers: { 'Content-Type' => 'application/json' })
          @params = { title: 'What a nice breeze.' }
          @breeze = Breeze.new(id: 1).save(@params)
        end
        it 'performs the API root request' do
          expect(root_request).to have_been_requested
        end
        it 'performs the save request' do
          expect(@save_request).to have_been_requested
        end
        it 'returns an item with the correct class' do
          expect(@breeze).to be_a_kind_of Breeze
        end
        it 'returns an item with the correct attributes' do
          expect(@breeze.id).to eq parsed_resource_response['id']
          expect(@breeze.title).to eq parsed_resource_response['title']
        end
      end

      context 'with an errored response' do
        before do
          root_request
          @save_request = WebMock.stub_request(:patch, "#{Breeze.config[:api_root_url]}/breezes/1")
                                 .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                  'Accept' => Breeze.config[:accept_header] })
                                 .to_return(status: 500)
        end
        it 'returns a Faraday::ClientError error' do
          expect do
            Breeze.new(id: 1).save(@params)
          end.to raise_error(Faraday::ClientError, 'the server responded with status 500')
          expect(root_request).to have_been_requested
          expect(@save_request).to have_been_requested
        end
      end

      context 'when overriding resource_find_options' do
        before do
          class Breeze
            def resource_find_options
              { id: id, token: token }
            end
          end

          root_request_with_token_resource_path
          @save_request = WebMock.stub_request(:patch, "#{Breeze.config[:api_root_url]}/breezes/1?token=123")
                                 .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                  'Accept' => Breeze.config[:accept_header] })
                                 .to_return(status: 200, body: resource_response,
                                            headers: { 'Content-Type' => 'application/json' })
          @params = { title: 'What a nice breeze.' }
          @breeze = Breeze.new(id: 1, token: 123).save(@params)
        end

        it 'performs the API root request' do
          expect(root_request_with_token_resource_path).to have_been_requested
        end

        it 'performs the save request' do
          expect(@save_request).to have_been_requested
        end

        it 'returns an item with the correct class' do
          expect(@breeze).to be_a_kind_of Breeze
        end

        it 'returns an item with the correct attributes' do
          expect(@breeze.id).to eq parsed_resource_response['id']
          expect(@breeze.title).to eq parsed_resource_response['title']
        end
      end
    end

    context '#destroy' do
      context 'under normal conditions' do
        before do
          root_request
          @destroy_request = WebMock.stub_request(:delete, "#{Breeze.config[:api_root_url]}/breezes/1")
                                    .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                     'Accept' => Breeze.config[:accept_header] })
                                    .to_return(status: 200)
          @breeze = Breeze.new(id: 1).destroy
        end
        it 'performs the API root request' do
          expect(root_request).to have_been_requested
        end
        it 'performs the destroy request' do
          expect(@destroy_request).to have_been_requested
        end
      end

      context 'with an errored response' do
        before do
          root_request
          @destroy_request = WebMock.stub_request(:delete, "#{Breeze.config[:api_root_url]}/breezes/1")
                                    .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                     'Accept' => Breeze.config[:accept_header] })
                                    .to_return(status: 500)
        end
        it 'returns a Faraday::ClientError error' do
          expect do
            Breeze.new(id: 1).destroy
          end.to raise_error(Faraday::ClientError, 'the server responded with status 500')
          expect(root_request).to have_been_requested
          expect(@destroy_request).to have_been_requested
        end
      end

      context 'when overriding resource_find_options' do
        before do
          class Breeze
            def resource_find_options
              { id: id, token: token }
            end
          end

          root_request_with_token_resource_path
          @destroy_request = WebMock.stub_request(:delete, "#{Breeze.config[:api_root_url]}/breezes/1?token=123")
                                    .with(headers: { 'Http-Authorization' => Breeze.config[:http_authorization_header],
                                                     'Accept' => Breeze.config[:accept_header] })
                                    .to_return(status: 200)
          @breeze = Breeze.new(id: 1, token: 123).destroy
        end
        it 'performs the API root request' do
          expect(root_request_with_token_resource_path).to have_been_requested
        end
        it 'performs the destroy request' do
          expect(@destroy_request).to have_been_requested
        end
      end
    end
  end
end
