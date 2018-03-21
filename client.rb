this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'objspace'

require 'grpc'
require 'helloworld_services_pb'

def call_gc
  puts "Running Garbage Collection..."
  GC.start
  puts "Ended Garbage Collection"
end

def call_hello_world
  count = 0

  loop do
    call_gc if count % 5 == 0

    puts "#{ObjectSpace.memsize_of_all(Helloworld::Greeter::Stub)} byte"

    stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)
    message = stub.say_hello(Helloworld::HelloRequest.new(name: 'world')).message
    p "Greeting: #{message}"

    count = count + 1
    sleep(0.5)
  end
end

call_hello_world
