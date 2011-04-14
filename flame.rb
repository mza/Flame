require 'rubygems'
require 'right_aws'
require 'yaml'
require 'net/http'
require 'uri'

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
    return benchmark
  end
end

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'
results_queue_name = options['queue'] || 'flame_results'

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)
results_queue = sqs.queue(results_queue_name)

while true
  message = queue.pop
  if message
    
    Flame.time_method('Flame run time') do    
      payload = YAML.parse(message.to_s)
      url = payload['url'].value
      load = payload['load'].value.to_i
      (1..load).each_with_index do |i, index|
        benchmark = Flame.time_method('Request time', true) do
          Net::HTTP.get URI.parse(url)
        end
        
        if benchmark
          payload = { 'url' => url, 'stamp' => Time.now, 'time' => benchmark }
          results_queue.send_message(payload.to_yaml)
        end
        
      end      
    end
    
  end
end