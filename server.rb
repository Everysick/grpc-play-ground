this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'pry'

require 'grpc'
require 'helloworld_services_pb'

require 'logging'

module GRPC
  extend Logging.globally
end

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger.root.level = :info
Logging.logger['GRPC'].level = :info
Logging.logger['GRPC::ActiveCall'].level = :info
Logging.logger['GRPC::BidiCall'].level = :info

module Interceptor
  class LoggingInterceptor < GRPC::Interceptor
    def request_response(request: nil, call: nil, method: nil)
      time = Time.now

      params = {
        service: method.receiver.class.service_name,
        ua: call.metadata['user-agent'],
        parameters: request.to_h,
      }

      GRPC.logger.info("[#{time}] Started Request: #{params}")
      yield
    end
  end
end

class GreeterService < Helloworld::Greeter::Service
  def say_hello(hello_req, _unused_call)
    Helloworld::HelloReply.new(message: "Hello #{hello_req.name}")
  end
end

def main
  s = GRPC::RpcServer.new(interceptors: [Interceptor::LoggingInterceptor.new])
  s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)

  s.handle(GreeterService)

  s.run_till_terminated
end

main
