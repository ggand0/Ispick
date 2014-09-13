# -*- coding: utf-8 -*-
class ActiveSupport::Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    "[#{severity}] [#{time.strftime("%Y-%m-%d %H:%M:%S")}]#{msg}\n"
  end
end