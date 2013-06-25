# encoding: UTF-8

require File.expand_path('../adapter/file', __FILE__)
require File.expand_path('../adapter/fluentd', __FILE__)

class FileAlternativeLogger
  class Adapter

    def initialize(level, device, name)
      @log_adapters = set_adaptor(level, device, name)
    end

    def write(level, device, name, msg)
      @log_adapters.each do |adapter|
        adapter.write(level, device, name, msg)
      end
    end

    def close
      @log_adapters.each do |adapter|
        adapter.close
      end
    end

    private
    def config
      config = {
        debug:   [FileAlternativeLogger::Adapter::File],
        info:    [FileAlternativeLogger::Adapter::File],
        warn:    [FileAlternativeLogger::Adapter::File],
        error:   [FileAlternativeLogger::Adapter::File],
        fatal:   [FileAlternativeLogger::Adapter::File],
        unknown: [FileAlternativeLogger::Adapter::File],
      }
      if Rails.env.staging? || Rails.env.production?
        config = config.each do |key, value|
          value << FileAlternativeLogger::Adapter::Fluentd
          {key => value}
        end
      end
      config
    end

    def set_adaptor(level, device, name)
      adapters = Array.new
      config[level].each do |adapter|
         adapters.push adapter.new(level, device, name)
      end
      adapters
    end

  end
end


