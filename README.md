# Bus Tracker
Simple bus tracker api service using TDX api.

Build image first with `docker build . -t bustracker`,
then use `docker-compose up` with supplied .env to start server.

Swagger api document available at `/swagger`

### Memos
* Start resque worker: `bundle exec env rake resque:workers QUEUE='*' COUNT='4'`
* Whenever (cron job): `whenever . --set environment=development`
* Swagger
    * Generate controller template `rails generate rspec:swagger MyController`
    * Generate doc `rake rswag`