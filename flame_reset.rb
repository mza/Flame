require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'
results_queue_name = options['queue'] || 'flame_results'

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)
results_queue = sqs.queue(results_queue_name)
simpledb = RightAws::SdbInterface.new(key, secret)

puts "Clearing queues"
queue.delete
results_queue.delete

puts "Cleaing SimpleDB"
simpledb.delete_domain(results_queue_name)
puts "Flame queues reset!"