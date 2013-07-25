server "ec2-54-245-113-145.us-west-2.compute.amazonaws.com", :app, :web, :primary => true
set :deploy_to, "/home/ubuntu/www/casino-sim/live"

set :deploy_via, :copy
set :copy_dir, "/Users/leonidas/www/casino-sim/live"
set :copy_remote_dir, "/home/ubuntu/www/casino-sim/live"

set :branch, fetch(:branch, "live_branch")
set :env, fetch(:env, "live")

run "cd #{latest_release} && tar -czf live_archive_$( date +%d%m%y%H%M).tgz ./live"
run "cd #{latest_release} && s3cmd mb s3://casino-live/"
run "cd #{latest_release} && s3cmd put live_archive_$( date +%d%m%y%H%M).tgz s3://casino-live/deploy/"
run "cd #{latest_release} && echo $( date +%d%m%y%H%M) > latest.txt"
run "cd #{latest_release} && s3cmd put latest.txt s3://casino-live/deploy/"
