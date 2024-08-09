service cron start
bundle exec whenever -w --set environment=development
while true; do sleep 1; done
