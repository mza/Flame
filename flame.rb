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
    puts "#{flag}: #{(end_time - beginning_time)*1000} milliseconds"
  end
end

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
    
    Flame.time_method('Flame run time') do    
      payload = YAML.parse(message.to_s)
      url = payload['url'].value
      load = payload['load'].value.to_i
      puts "Requesting: #{url}"
      puts "Requests: #{load}"
      (1..load).each_with_index do |i, index|
        Flame.time_method('Request time') do
          puts "[ #{index} of #{load} ] #{url}"
        end
        # Net::HTTP.get_print URI.parse(url)
      end
      puts "Flamed!"
    end
    
  end
  sleep 5
end