default_run_options[:pty] = true
require 'capistrano/ext/multistage'
set :application, "casino-sim"
set :repository,  "https://github.com/lossas/casino_sim.git"
set :scm, :git
set :user, "ubuntu"

set :stages, ["beta", "live"]
set :default_stage, "beta"

set :use_sudo ,"false"
ssh_options[:forward_agent] = true

role :web, "ec2-54-245-113-145.us-west-2.compute.amazonaws.com"                          # Your HTTP server, Apache/etc
role :app, "ec2-54-245-113-145.us-west-2.compute.amazonaws.com"                          # This may be the same as your `Web` server