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


$config[:targets].each do |target, options|

  unless Dir.exists?(target)
    Log.warn("Target '#{target}' does not exist, skipping")
    next
  end

  # placeholders
  last_kept = last = nil

  # make sure the files are sorted first (newest first)
  Pathname.new(target).each_child.sort{|a, b| b.mtime <=> a.mtime }.each do |entry|

    # only work with files, unless explicitly told to work on directories
    unless options[:prune_directories]
      next unless entry.file?
    end

    # allways keep newest backup
    unless last
      last_kept = last = entry
      next
    end

    [:daily, :weekly, :monthly].each do |interval|

      # mtime of file/entry is within setting for interval
      if $config[:keep][interval] and entry.mtime >= $config[:keep][interval]
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

        # still within max_age, try next file/entry
        if (last_kept.mtime - entry.mtime) <= max_age
          if last != last_kept
            Log.info("#{interval} delete: #{last}")
            last.delete unless $config[:dry_run]
          end

        # over max_age, use last
        else
            #Log.info("#{interval} keep: #{last}")
            last_kept = last
        end
        # update pointer to last file/entry object
        last = entry
        # avoid going into next interval
        break
      end
    end
  end
end
