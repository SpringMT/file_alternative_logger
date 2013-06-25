# encoding: UTF-8

class FileAlternativeLogger
  class Adapter
    class File
      def initialize(level, device, name)
        # pathは環境によって切り替える
        @path = !defined?(Rails.env)  ? Rails.root.join('log')
              : Rails.env.production? ? 'log'
              : Rails.env.staging?    ? 'log'
              :                         Rails.root.join('log')
        unless Dir.exist? @path
          raise StandardError, "Not Exist #{@path}"
        end

        logname = "#{device}_#{name}"
        @log = open_logfile(level, logname)
        @today = Time.now.strftime "%Y%m%d"
      end

      def write(level, device, name, msg)
        # 日付をまたいだ時は新しい日付のファイルに書き出す
        if @log.nil? || !same_date?
          logname = "#{device}_#{name}"
          @log = create_logfile(level, logname)
        end
        @log.write msg
      end

      def close
        unless @log.nil?
          @log.close
        end
      end

      # ファイルがない場合はnilを返す
      private
      def open_logfile(level, name)
        today = Time.now.strftime "%Y%m%d"
        filename = "#{@path}/#{name}.#{today}.#{level}.log"
        return nil unless ::File.exist? filename
        # ファイルは作らない
        f = ::File.open filename, (::File::WRONLY | ::File::APPEND)
        f.binmode
        f.sync = true
        f
      end

      def create_logfile(level, name)
        today = Time.now.strftime "%Y%m%d"
        filename = "#{@path}/#{name}.#{today}.#{level}.log"
        f = ::File.open filename, 'a'
        f.binmode
        f.sync = true
        f
      end

      def same_date?
        @today == Time.now.strftime("%Y%m%d")
      end
    end

  end
end


