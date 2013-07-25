server "ec2-54-245-113-145.us-west-2.compute.amazonaws.com", :app, :web, :primary => true
set :deploy_to, "/home/ubuntu/www/casino-sim/live"

set :deploy_via, :copy
set :copy_dir, "/Users/leonidas/www/casino-sim/live"
set :copy_remote_dir, "/home/ubuntu/www/casino-sim/live"

set :branch, fetch(:branch, "live_branch")
set :env, fetch(:env, "live")

   def remote_file_exists?(full_path)
      'true' ==  capture("if [ -s #{full_path} ]; then echo 'true'; fi").strip
   end

desc "Deploy to live ---- Upload to S3"
task :live_uploadToS3 do
  run "cd #{latest_release} && tar -czf live_archive_$( date +%d%m%y%H%M).tgz ./live"
  run "cd #{latest_release} && s3cmd mb s3://casino-live/"
  run "cd #{latest_release} && s3cmd put live_archive_$( date +%d%m%y%H%M).tgz s3://casino-live/deploy/"
  run "cd #{latest_release} && echo $( date +%d%m%y%H%M) > latest.txt"
  run "cd #{latest_release} && s3cmd put latest.txt s3://casino-live/deploy/"
end

desc "Download latest from Live"
task :download_latest_fromLive do
  run "mkdir -p /home/ubuntu/www/casino-sim/live/temp_latest"
  run "s3cmd get s3://casino-live/deploy/latest.txt /home/ubuntu/www/casino-sim/live/temp_latest --force"
  if remote_file_exists?('/home/ubuntu/www/casino-sim/live/temp_latest/latest.txt')
    run "timestamp=$(cat /home/ubuntu/www/casino-sim/live/temp_latest/latest.txt) && echo The timestamp is: $timestamp"
  end
end

desc "Live Rollback"
task :live_rollback do
  run "mkdir -p /home/ubuntu/www/casino-sim/live/previous"
  run "s3cmd get s3://casino-live/deploy/live_archive_#{timestamp}.tgz /home/ubuntu/www/casino-sim/live/previous --force" 
end