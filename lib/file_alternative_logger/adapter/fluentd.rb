# encoding: UTF-8

require 'fluent-logger'
require 'socket'

class FileAlternativeLogger
  class Adapter
    class Fluentd
      HOSTNAME = Socket.gethostname

      def initialize(level, device, name)
        @log = nil
      end

      def write(level, device, name, msg)
        @log ||= Fluent::Logger::FluentLogger.new('log', host: 'localhost', port: 24224)
        tag = "#{level}.#{device}.#{name}.#{HOSTNAME}"
        @log.post(tag, {message: msg})
      end

      def close
        unless @log.nil?
          @log.close
        end
      end

    end

  end
end


