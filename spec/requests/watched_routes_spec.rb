require 'swagger_helper'

RSpec.describe 'watched_routes', type: :request do
  path '/api/v1/watched_routes/get' do
    parameter(
      name: :email, in: :body,
      schema: {
        type: :object,
        properties: {
          email: { type: :string },
        },
        required: %w(email)
      }
    )
    post('Get list of watched routes') do

      response(200, 'ok') do
        schema type: :object, properties: {
          email: { type: :string },
        }
        run_test!
      end

      response(400, 'bad request') do 
        run_test!
      end
    end
  end

  path '/api/v1/watched_routes/add' do
    parameter(
      name: :watch_route, in: :body,
      schema: {
        type: :object,
        properties: {
          email: { type: :string },
          city: { type: :string },
          route_id: { type: :string },
          route_name: { type: :string },
          direction: { type: :integer },
          alert_stop_id: { type: :string },
        },
        required: %w(email city route_id route_name direction alert_stop_id)
      }
    )

    post('Add watched route and stop') do
      response(200, 'already exists') do
        schema type: :object, properties: {
          email: { type: :string },
          city: { type: :string },
          route_id: { type: :string },
          route_name: { type: :string },
          direction: { type: :integer },
          alert_stop_id: { type: :string },
        }
        run_test!
      end

      response(201, 'created') do
        schema type: :object, properties: {
          email: { type: :string },
          city: { type: :string },
          route_id: { type: :string },
          route_name: { type: :string },
          direction: { type: :integer },
          alert_stop_id: { type: :string },
        }
        run_test!
      end

      response(400, 'bad request') do 
        run_test!
      end
    end
  end

  path '/api/v1/watched_routes/delete' do
    parameter(
      name: :delete_route, in: :body,
      schema: {
        type: :object,
        properties: {
          email: { type: :string },
          city: { type: :string },
          route_id: { type: :string },
          alert_stop_id: { type: :string },
        },
        required: %w(email city route_id alert_stop_id)
      }
    )
    
    delete('Delete a watched route') do
      response(200, 'ok') do
        schema type: :object, properties: {
          email: { type: :string },
          city: { type: :string },
          route_id: { type: :string },
          alert_stop_id: { type: :string },
        }
        run_test!
      end

      response(400, 'bad request') do 
        run_test!
      end
    end
  end
end
