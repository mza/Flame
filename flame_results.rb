#! /usr/bin/env ruby

require 'rubygems'
require 'right_aws'
require 'yaml'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
results_queue_name = options['results_queue'] || 'flame_results'

filename = "results.txt"
log = Logger.new(filename)
log.level = Logger::DEBUG

sqs = RightAws::SqsGen2.new(key, secret)
results_queue = sqs.queue(results_queue_name)

log.info "Flame results monitor: polling..."

counter = 0.0
total = 0.0

while true
  messages = results_queue.receive_messages(10,20)
  
  messages.each do |message|
    payload = YAML.parse(message.to_s)
    url = payload['url'].value
    time = payload['time'].value  
    stamp = payload['stamp'].value  
    counter = counter + 1
    total = total + time.to_f
    if (counter % 20) == 0
      puts "Result count: #{counter}"
      puts "Average load time so far: #{total/counter} ms"
    end
    log.info "#{url}, #{stamp}, #{time}"  
    message.delete
  end
  
end