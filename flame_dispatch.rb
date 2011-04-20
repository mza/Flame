require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'
results_queue_name = options['queue'] || 'flame_results'

workers = ARGV[0]
load = ARGV[1]
url = ARGV[2]

payload = { 'url' => url, 'load' => load.to_i }

puts "Dispatch: #{payload.to_yaml}"
puts queue_name
puts "Checking SimpleDB domain is available..."
simpledb = RightAws::SdbInterface.new(key, secret)
simpledb.create_domain(results_queue_name)
puts "OK"

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)

(1..workers.to_i).each_with_index do |i, index| 
  puts "Scheduling Flame run: #{i} of #{workers}"
  queue.send_message(payload.to_yaml)
end