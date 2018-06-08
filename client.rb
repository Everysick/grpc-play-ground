this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'pry'

require 'grpc'
require 'helloworld_services_pb'

# simulate #15314
def call_10000
  stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)
  request = Helloworld::HelloRequest.new(name: 'world')
  count = 0

  10000.times do
    begin
      stub.say_hello(request, deadline: Time.now.to_f + 0)
      count += 1
    rescue
    end
  end

  puts count
end

call_10000
