require 'optparse'
require 'pp'
require 'yaml'

default_options = {
  :color => true,
  :verbose => false,
  :configfile => '/etc/prune-backups.yml',
  :keep => {
    :daily => '7d',
    :weekly => '1y',
  }
}

options = default_options

OptionParser.new do |opts|
  opts.banner = "Usage: syncagent.rb [options]"
  opts.on('-v', '--verbose', 'Run verbosely') { options[:verbose] = true }
  opts.on('-f', '--configfile PATH', String, 'Set config file') {|path| options[:configfile] = path }
end.parse!

begin
  yaml = Hash[YAML.load_file(options[:configfile])]
  yaml.delete(:configfile)
  options.merge!(yaml)
rescue Exception => e
  Log.fatal("Unable to load config (YAML) from '#{options[:configfile]}': #{e.message}")
  exit(false)
end

# Check we have configured some servers
unless options[:targets].kind_of?(Hash) and not options[:targets].empty?
  Log.fatal("Error: 'targets' option must contain at least one target (Hash).")
  exit(false)
end

# debug
#options[:targets].each do |t|
#  pp t
#end

# check keep settings are valid
if options[:keep].nil? or not options[:keep].respond_to?(:include?)
  Log.fatal("Error: 'keep' option must be set correctly")
  exit(false)
end

now = Time.now
match = 0
[:daily, :weekly, :monthly].each do |interval|
  Log.debug("Checking for interval: '#{interval}'")
  if options[:keep].include?(interval)
    Log.debug("Found keep-interval: '#{interval}'")
    match += 1
    # valid format
    unless /^(\d+)([ywmd])$/.match(options[:keep][interval])
      Log.fatal("Invalid keep interval '#{interval}:#{options[:keep][interval]}', interval must be a number followed by either 'd', 'm', 'w' or 'y'")
      exit(false)
    end

    # The program will only consider one resolution at a time, 
    # this means as long as it's doing daily, weekly is not considered. 

    # When the period of daily backups stop, program will start 
    # considering weekly, after weekly monthly, etc..
    # We help the program by converting the time formats into dates it can match against.

    distance, type = $1.to_i, $2 # from regex above

    if distance <= 0
      Log.fatal("Error, distance cannot be 0 (interval: #{options[:keep][interval]})")
      exit(false)
    end

    case type
    when 'y'
      options[:keep][interval] = Time.new(now.year - distance, now.month, now.day, now.hour, now.min, now.sec)

    when 'm'
      years = distance % 12
      months = distance - (years * 12)
      options[:keep][interval] = Time.new(now.year - years, now.month - months, now.day, now.hour, now.min, now.sec)
      
    when 'w'
        options[:keep][interval] = now - (distance * 7 * 24 * 60 * 60) # subtract weeks
      
    when 'd'
        options[:keep][interval] = now - (distance * 24 * 60 * 60) # subtract days
      
    else
      Log.fatal("Unsupported distance '#{distance}' for 'keep' setting")
      exit(false)
    end
  end

  if match == 0
    Log.fatal("One of these keep-intervals must be configured: 'daily', 'weekly', or 'monthly'")
    exit(false)
  end
end

# global
$config = options
