require 'lib/constants'

class Logger

  include Constants::Shell
  
  # taken from FBSDBot
  attr_reader :level
  attr_accessor :color
  
  LOG_LEVELS = {
    :debug => 0,
    :info  => 1,
    :warn  => 2,
    :error => 3,
    :fatal => 4,
    :off   => 5
  }
  
  def initialize
    @level = :debug
    @color = true
  end
  
  def level=(level)
    unless LOG_LEVELS.keys.include?(level)
      raise "log level must be one of #{LOG_LEVELS.keys.join(', ')}"
    end
    
    @level = level
  end
  
  def debug(msg, obj = nil)
    log __method__.to_sym, msg, obj
  end
  
  def info(msg, obj = nil)
    log __method__.to_sym, msg, obj
  end
  
  def warn(msg, obj = nil)
    log __method__.to_sym, msg, obj
  end
  
  def error(msg, obj = nil)
    log __method__.to_sym, msg, obj
  end
  
  def fatal(msg, obj = nil)
    log __method__.to_sym, msg, obj
  end
  
  private
  
  def log(type, msg, obj)
    return if @level == :off
    
    msg_level = LOG_LEVELS[type]
    cur_level = LOG_LEVELS[@level]
    
    return unless msg_level >= cur_level
    
    # use STDERR and red color for warnings and higher importance
    out, red = msg_level >= LOG_LEVELS[:warn] ? [$stderr, true] : [$stdout, false]
    msg = msg.inspect unless msg.respond_to?(:to_str)
    
    if @color && out.tty?
      out.puts "#{Color::GRAY}#{Time.now.strftime("%F %T")} #{RESET}(#{red ? Color::RED : Color::YELLOW}#{type}#{RESET}) #{obj} :: #{BOLD}#{msg}#{RESET}"
    else
      out.puts "#{Time.now.strftime("%F %T")} (#{type}) #{obj} :: #{msg}"
    end
  end
end

