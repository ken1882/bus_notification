# Bus Tracker
Simple bus tracker api service using TDX api.

Build image first with `docker build . -t bustracker`,
then use `docker-compose up` with supplied .env to start local server.

Swagger api document available at `/swagger`

### Quick walkthrough
* TDX token not needed as long as `wildproxies.yml` is adequately supplied.
* Email verification and authentication not implemented (only simple format checks).
* Route Data:
    * `GET /bus_routes` get list of available cities.
    * `GET /bus_routes/:city` get all available routes and stops of city.
    * `GET /bus_routes/:city/routes/:route_name` get live data of given parameters.
        * Result is limited to 100 entries.
        * `response['has_more']` indicates if more unfetched data is available.
        * Use `?page=n+1` to get next batch of data, where `n` starts from 0.
* Watched Routes:
    * `POST /watched_routes/add` registers a watched bus route (up to 10 per email).
        * Will send an email notification if bus is expected to arrive within 3 minutes.
    * `POST /watched_routes/get` get list of watched routes
    * `DELETE /watched_routes/remove` removes a watched route

### Memos
* Start resque worker: `bundle exec env rake resque:workers QUEUE='*' COUNT='4'`
* Whenever (cron job): `whenever . --set environment=development`
* Swagger
    * Generate controller template: `rails generate rspec:swagger MyController`
    * Generate doc: `rake rswag`
