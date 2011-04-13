require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'

puts queue_name

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)

while true
  puts 'Popping queue'
  message = queue.pop
  if message
    puts "Received: #{message}"
  end
  sleep 5
end