#!/usr/bin/env ruby
require "rubygems"
require 'bundler/setup'
Bundler.require

$:.unshift(File.expand_path('../lib', File.dirname(__FILE__)))
require 'vervet_monkeys'

case ARGV.first
when 'config'
  puts Dir.glob(VervetMonkeys::CONFIG_DIR + '**/*')
when 'reset'
  FileUtils.rm Dir.glob(VervetMonkeys::DATA_DIR + '*')
when nil, 'watch'
  VervetMonkeys::Monkey.new.watch
else
  executable = __FILE__.sub(/\.rb$/,'')
  puts <<-end_string
usage: #{executable} [command] [args]

in a crontab:
* /2 * * * /bin/sh -c '#{File.expand_path(__FILE__).chop.chop.chop}' >/dev/null 2>&1

Running #{executable} without any arguments will have the same effect as the
watch command.

  config  List all config files
  help    Shows this message
  reset   Remove all data; all pages will be "new" again
  watch   Watch for changes in the configured urls
end_string
end
