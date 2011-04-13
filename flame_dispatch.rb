require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'

command = ARGV[0]

puts "Dispatch: #{command}"
puts queue_name

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)

queue.send_message(command)