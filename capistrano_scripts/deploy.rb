default_run_options[:pty] = true
require 'capistrano/ext/multistage'
set :normalize_asset_timestamps, false
set :application, "yacg_sim"
set :repository,  "https://github.com/lossas/casino_sim.git"
set :scm, :git
set :user, "ubuntu"

set :stages, ["beta", "live"]
set :default_stage, "beta"

set :use_sudo ,"false"
ssh_options[:forward_agent] = true
ssh_options[:keys]=["/home/ubuntu/.ssh/leokeypair.pem"]
#role :web, "ec2-54-245-113-145.us-west-2.compute.amazonaws.com"
#role :app, "ec2-54-245-113-145.us-west-2.compute.amazonaws.com" 
role :app, ""
