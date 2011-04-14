require 'rubygems'
require 'right_aws'
require 'yaml'

class Flame
  def self.time_method(flag='Time elapsed', method=nil, *args)
    beginning_time = Time.now
    if block_given?
      yield
    else
      self.send(method, args)
    end
    end_time = Time.now
    benchmark = (end_time - beginning_time)*1000
    puts "#{flag}: #{benchmark} ms"
    return benchmark
  end
end

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

  # Using SimpleDB
  
  simpledb = RightAws::SdbInterface.new(key, secret)
  
  while true
    counter = 0.0
    total = 0.0
    
    query = "select time from #{results_queue_name} limit 2500"
    results = simpledb.select(query)
    items = results[:items]
  
    puts "Result count: #{items.size}"  
    items.each do |item|
      time = item[item.keys[0]]["time"][0]
      total = total + time.to_f
    end
    puts "Average load time: #{total/items.size}"
    puts ""
    sleep 3
  end
  
  # Using SQS:  
  # @messages = results_queue.receive_messages(10,43200)
  # 
  # while true
  # @messages.each do |message|
  #   payload = YAML.parse(message.to_s)
  #   url = payload['url'].value
  #   time = payload['time'].value  
  #   stamp = payload['stamp'].value  
  #   counter = counter + 1
  #   total = total + time.to_f
  #   if (counter % 20) == 0
  #     puts "Result count: #{counter}"
  #     puts "Average load time so far: #{total/counter} ms"
  #   end
  #   log.info "#{url}, #{stamp}, #{time}"    
  #   message.delete    
  # end  
  # end