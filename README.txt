FLAME
-----

A super simple, distributed load tester. It acts to drive loads to a website and monitor the performance.
Think of it as a simple Apache Benchmark, distributed to mimic real world requests more accurately.

Flame consists of three components:

+ Flame Worker, which actually performs the job of pushing load to a server
+ Flame Dispatch, which dispatches load tasks to the workers
+ Flame Results, which collates results from the workers

To run Flame, you'll need a fee Amazon Web Services account, and access to the Simple Queue Service, SQS.
Put your key and secret key in a file called 'config.yml', as show in the 'config.default' example.

+ Quick start

Whilst Flame is designed to work in a distributed cloud environment, you can just as easily run smaller tests from your laptop. 
You'll need the RightScale AWS gem:

sudo gem install right_aws

Add your AWS credentials to the config.yml file.

key: 'EXAMPLE_KEY'
secret: 'EXAMPLE_SECRET'

Then start a single Flame worker, and leave it running:

ruby flame.rb

Start the Flame results monitor:

ruby flame_results.rb

Then dispatch a simple load test for the worker to perform:

ruby flame_dispatch 1 50 http://your-ec2-instance-public-dns.amazonaws.com

This will drive a single worker to request the above URL 50 times.

After a while, you should see output from the results monitor:

Result count: 50.0
Average load time so far: 806.381204 ms

You can also view the entire log in the results.txt file, in CSV format ready to import
into the spreadsheet of your choice.



