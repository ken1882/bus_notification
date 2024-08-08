# Bus Tracker
Simple bus tracker api service using TDX api.

Use `docker-compose up` with supplied .env to start server.

* Memos
    * Start resque worker: `bundle exec env rake resque:workers QUEUE='*' COUNT='4'`
    * Whenever (cron job): `whenever . --set environment=development`
    * Swagger
        * Generate controller template `rails generate rspec:swagger MyController`
        * Generate doc `rake rswag`