this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'helloworld_services_pb'

def call_hello_world
  stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)
  message = stub.say_hello(Helloworld::HelloRequest.new(name: 'world')).message
  p "Greeting: #{message}"
end

call_hello_world
