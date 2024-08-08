require 'swagger_helper'

RSpec.describe 'bus_routes', type: :request do
  path '/api/v1/bus_routes' do
    get('List cities available for bus routes') do
      response(200, 'ok') do
        let(:city) { 'Taipei' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/bus_routes/{city}' do
    parameter name: 'city', in: :path, type: :string, description: 'city name in English'
    get('shows all routes and stops info of given city') do
      response(200, 'ok') do
        let(:city) { 'Taipei' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/bus_routes/{city}/routes/{route_name}' do
    parameter name: 'city', in: :path, type: :string, description: 'city name in English'
    parameter name: 'route_name', in: :path, type: :string, description: 'city name in Zh_tw'
    
    get('Get live status of given city and bus route') do
      response(200, 'ok') do
        let(:city) { 'Taipei' }
        let(:route_name) { '234' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
