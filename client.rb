this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'objspace'

require 'pry'

require 'grpc'
require 'helloworld_services_pb'

module ExtRunBatch
  def run_batch(*args)
    puts "Before send: #{ObjectSpace.memsize_of_all(GRPC::Core::MetadataArray)} byte"
    res = super(*args)
    puts "After send: #{ObjectSpace.memsize_of_all(GRPC::Core::MetadataArray)} byte"
    res
  end
end

module GRPC
  module Core
    class Call
      prepend ExtRunBatch
    end
  end
end

def call_gc
  puts "Running Garbage Collection..."
  GC.start
  puts "Ended Garbage Collection"
end

def call_hello_world
  loop do
    # call_gc

    sleep(0.5)

    stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)
    message = stub.say_hello(Helloworld::HelloRequest.new(name: 'world'), metadata: { header: 'header' }).message
    p "Greeting: #{message}"

    sleep(0.5)
  end
end

call_hello_world
