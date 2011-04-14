FLAME
-----

A super simple, distributed load tester.

Flame consists of three components:

+ Flame Worker, which actually performs the job of pushing load to a server
+ Flame Dispatch, which dispatches load tasks to the workers
+ Flame Results, which collates results from the workers

To run Flame, you'll need a fee Amazon Web Services account, and access to the Simple Queue Service, SQS.
Put your key and secret key in a file called 'config.yml', as show in the 'config.default' example.





