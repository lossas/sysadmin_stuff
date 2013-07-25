server "ec2-54-245-113-145.us-west-2.compute.amazonaws.com", :app, :web, :primary => true
set :deploy_to, "/home/ubuntu/www/casino-sim/beta/"

set :deploy_via, :copy
set :copy_dir, "/Users/leonidas/www/casino-sim/beta"
set :copy_remote_dir, "/home/ubuntu/www/casino-sim/beta/"

set :branch, "beta_branch"

run "cd #{latest_release} && tar -czf beta_archive_$( date +%d%m%y%H%M).tgz ./beta"
run "cd #{latest_release} && s3cmd mb s3://casino-beta/"
run "cd #{latest_release} && s3cmd put beta_archive_$( date +%d%m%y%H%M).tgz s3://casino-beta/deploy/"
run "cd #{latest_release} && echo $( date +%d%m%y%H%M) > latest.txt"
run "cd #{latest_release} && s3cmd put latest.txt s3://casino-beta/deploy/"