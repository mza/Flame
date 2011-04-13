require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require 'uri'

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
    payload = YAML.parse(message.to_s)
    url = payload['url'].value
    load = payload['load'].value.to_i
    puts "Requesting: #{url}"
    puts "Requests: #{load}"
    (1..load).each_with_index do |i, index|
      puts "[ #{index} of #{load} ] #{url}"
      Net::HTTP.get_print URI.parse(url)
    end
  end
  sleep 5
end