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
    super
    puts "After send: #{ObjectSpace.memsize_of_all(GRPC::Core::MetadataArray)} byte"
  end
end

module GRPC
  module Core
    class Call
      include ExtRunBatch
    end
  end
end

def call_gc
  puts "Running Garbage Collection..."
  GC.start
  puts "Ended Garbage Collection"
end

def call_hello_world
  call_gc
  stub = Helloworld::Greeter::Stub.new('localhost:50051', :this_channel_is_insecure)
  message = stub.say_hello(Helloworld::HelloRequest.new(name: 'world'), metadata: { header: 'header' }).message
  p "Greeting: #{message}"
end

call_hello_world
