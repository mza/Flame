require 'right_aws'

options = YAML::load(File.open('config.yml'))

key = options['key']
secret = options['secret']
queue_name = options['queue'] || 'flame_default'
results_queue_name = options['queue'] || 'flame_results'

sqs = RightAws::SqsGen2.new(key, secret)
queue = sqs.queue(queue_name)
results_queue = sqs.queue(results_queue_name)

queue.clear
results_queue.clear