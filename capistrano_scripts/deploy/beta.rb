server "", :app, :primary => true
set :deploy_to, "/home/ubuntu/www/casino_sim/beta/"

set :deploy_via, :copy
set :copy_dir, "/home/ubuntu/beta"
#set :copy_remote_dir, "/home/ubuntu/www/casino_sim/beta/"

set :branch, "beta_branch"

   def remote_file_exists?(full_path)
      'true' ==  capture("if [ -s #{full_path} ]; then echo 'true'; fi").strip
   end

#namespace :deploytoBeta do
desc "Deploy to beta ---- Upload to S3"
task :beta_uploadToS3 do
  run "cd #{latest_release} && tar -czf beta_archive_$( date +%d%m%y%H%M).tgz ./beta"
  run "cd #{latest_release} && s3cmd mb s3://casino-beta/"
  run "cd #{latest_release} && s3cmd put beta_archive_$( date +%d%m%y%H%M).tgz s3://casino-beta/deploy/"
  run "cd #{latest_release} && echo $( date +%d%m%y%H%M) > latest.txt"
  run "cd #{latest_release} && s3cmd put latest.txt s3://casino-beta/deploy/"
#end

#desc "Download latest from Beta"
#task :download_latest_fromBeta do
  run "mkdir -p /home/ubuntu/www/casino_sim/beta/temp_latest"
  run "s3cmd get s3://casino-beta/deploy/latest.txt /home/ubuntu/www/casino_sim/beta/temp_latest --force"
  if remote_file_exists?('/home/ubuntu/www/casino_sim/beta/temp_latest/latest.txt')
    run "timestamp=$(cat /home/ubuntu/www/casino_sim/beta/temp_latest/latest.txt) && echo The timestamp is: $timestamp"
  end
end
#end
