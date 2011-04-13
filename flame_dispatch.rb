require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'

load = ARGV[0]
url = ARGV[1]

payload = { 'url' => url, 'load' => load.to_i }

puts "Dispatch: #{payload.to_yaml}"
puts queue_name

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)

queue.send_message(payload.to_yaml)