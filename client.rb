this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'pry'

require 'grpc'
require 'helloworld_services_pb'

require 'logger'

host = ENV.fetch('HOST') || '0.0.0.0'
port = ENV.fetch('PORT') || '50051'

logger = Logger.new('/proc/1/fd/1')
logger.level = Logger::INFO
logger.info("Target server: #{host}:#{port}")

loop do
  stub = Helloworld::Greeter::Stub.new(
    "#{host}:#{port}",
    :this_channel_is_insecure,
  )
  request = Helloworld::HelloRequest.new(name: 'world')

  begin
    logger.info('Sending request')
    res = stub.say_hello(request, deadline: Time.now.to_f + 4) # Too long time
    logger.info("Response: #{res}")
  rescue => e
    logger.warn("Detect error: #{e}")
  end

  sleep(5)
end
