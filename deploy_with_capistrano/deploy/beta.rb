server "ec2-54-245-113-145.us-west-2.compute.amazonaws.com", :app, :web, :primary => true
set :deploy_to, "/home/ubuntu/www/casino-sim/beta/"

set :deploy_via, :copy
set :copy_dir, "/Users/leonidas/www/casino-sim/beta"
set :copy_remote_dir, "/home/ubuntu/www/casino-sim/beta/"

set :branch, "beta_branch"

   def remote_file_exists?(full_path)
      'true' ==  capture("if [ -s #{full_path} ]; then echo 'true'; fi").strip
   end

desc "Deploy to beta ---- Upload to S3"
task :beta_uploadToS3 do
  run "cd #{latest_release} && tar -czf beta_archive_$( date +%d%m%y%H%M).tgz ./beta"
  run "cd #{latest_release} && s3cmd mb s3://casino-beta/"
  run "cd #{latest_release} && s3cmd put beta_archive_$( date +%d%m%y%H%M).tgz s3://casino-beta/deploy/"
  run "cd #{latest_release} && echo $( date +%d%m%y%H%M) > latest.txt"
  run "cd #{latest_release} && s3cmd put latest.txt s3://casino-beta/deploy/"
end

desc "Download latest from Beta"
task :download_latest_fromBeta do
  run "mkdir -p /home/ubuntu/www/casino-sim/beta/temp_latest"
  run "s3cmd get s3://casino-beta/deploy/latest.txt /home/ubuntu/www/casino-sim/beta/temp_latest --force"
  if remote_file_exists?('/home/ubuntu/www/casino-sim/beta/temp_latest/latest.txt')
    run "timestamp=$(cat /home/ubuntu/www/casino-sim/beta/temp_latest/latest.txt) && echo The timestamp is: $timestamp"
  end
end

desc "Beta Rollback"
task :beta_rollback do
  run "mkdir -p /home/ubuntu/www/casino-sim/beta/previous"
  run "s3cmd get s3://casino-beta/deploy/beta_archive_#{timestamp}.tgz /home/ubuntu/www/casino-sim/beta/previous --force" 
end