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
  counter = 0.0
  total = 0.0
    
  while true
    old_counter = counter    
    old_total = total
    
    counter = 0.0
    total = 0.0
    page = 1
    query = "select time from #{results_queue_name} limit 2500"
    
    results = simpledb.select(query)
    items = results[:items]
    next_token = results[:next_token]    
    
    puts "Select from SimpleDB: page #{page} -> #{items.size} items"

    items.each do |item|
      time = item[item.keys[0]]["time"][0]
      total = total + time.to_f
      counter = counter + 1
    end
    
    while next_token
      
      page = page + 1      
      results = simpledb.select(query, next_token)            
      items = results[:items]
      next_token = results[:next_token]    
      
      puts "Paging from SimpleDB: page #{page} -> #{items.size} items"
    
      items.each do |item|
        time = item[item.keys[0]]["time"][0]
        total = total + time.to_f
        counter = counter + 1
      end
                            
    end
    
    puts "Result count: #{counter}"      
    puts "Average load time: #{total/counter}"
    puts "Result delta: #{counter - old_counter} items"
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