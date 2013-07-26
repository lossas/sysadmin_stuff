In this branch there are two folders where you can find some capistrano-scripts.

capistrano_scripts ===> The develop- and deploy-machine is the same. We assume that we have two different branches (live and beta) 
and we want to deploy to each one of them. The deployment scripts are doing the following:
create a tar-archive of the branch following by a timestamp and an latest.txt file that contains only the latest timestamp.
Next it upload those files to an S3 bucket.
After that it gets the latest.txt file and it prints the timestamp (the content of the file)

deploy_with_capistrano ====> Actually it makes the same things , but we assume in this case that the develo- and the deploy-machine
are two different machines.
