#!/usr/bin/env ruby

require 'optparse'
require 'pathname'
require 'yaml'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

# Setup logger
require 'lib/logger.rb'
Log = Logger.new
Log.level = :info

require 'lib/config.rb'
require 'lib/constants.rb'

now = Time.now

$config[:targets].each do |target, options|

  unless Dir.exists?(target)
    Log.warn("Target '#{target}' does not exist, skipping")
    next
  end

  # placeholders
  last_kept = last = nil

  # make sure the files are sorted first (newest first)
  Pathname.new(target).each_child.sort{|a, b| b.mtime <=> a.mtime }.each do |file|

    # allways keep newest backup
    unless last
      last_kept = last = file
      next
    end

    [:daily, :weekly, :monthly].each do |interval|

      # mtime of file is within setting for interval
      if $config[:keep][interval] and file.mtime >= $config[:keep][interval]

        Log.info("#{interval} proc #{file}")

        max_age = case interval
                  when :daily
                    Constants::Time::DAY
                  when :weekly
                    Constants::Time::WEEK
                  when :monthly
                    Constants::Time::MONTH
                  else
                    raise
                  end

        # still within max_age, try next file
        if (last_kept.mtime - file.mtime) < max_age
          if last != last_kept
            Log.info("#{interval} delete: #{last}")
            last = file
            break
          end
        
        # equal to max_age
        elsif (last_kept.mtime - file.mtime) == max_age
          if last != last_kept
            Log.info("#{interval} delete: #{last}")
          end

          Log.info("#{interval} keep: #{file}")
          last_kept = last = file
          break

        # over max_age
        else
          # continue here..
        end
      end
    end
  end
end
