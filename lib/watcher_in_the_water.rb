#!/usr/bin/env ruby

require "rubygems"
require 'bundler/setup'
Bundler.require

require 'open-uri'
require 'yaml'
require 'digest/sha1'
require 'fileutils'


module WatcherInTheWater

  HELP = <<-end_help
You need {{config}} to contain a sender jabber ID, password,
a recipient jabber ID, and a list of URLs in YAML format. Example:

---
jid: watcher-in-the-water@jabber.org
password: mellon
recipient: phil@hagelb.org
urls: ---
  http://rubyconf.org
end_help


  include Jabber
  VERSION = '0.1'

  module_function

  def configure(config_file = nil)
    config_file ||= "~/.watcher/config.yml"
    filename = File.expand_path(config_file)
    # FileUtils.cd(File.dirname(filename))
    @config = YAML.load(File.read(filename))
  rescue
    abort HELP.gsub("{{config}}", filename)
  end

  def watch
    @config['urls'].each do |url|
      content = open(url).read
      hash = Digest::SHA1.hexdigest(content)
      filename = 'hashes/' + url_transform(url)

      if File.exist?(filename)
        if File.read(filename) != hash
          alert("#{url} changed to #{content[0 .. 200]}")
        end
      else
        alert("Watching #{url} for you!")
      end
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w') { |f| f.write hash }
    end
  end

  def alert(message)
    connect
    @client.send Message.new(@config['recipient'],
                             message).set_type(:normal).set_id('1')
  end

  def connect
    return if @client
    jid = JID.new("#{@config['jid']}/#{`hostname`.chomp}-watcher")
    @client = Client.new(jid)
    @client.connect
    @client.auth(@config['password'])
  end

  def url_transform(url)
    url.gsub(/[^\w]/, '_')[0 .. 50] + '_' + Digest::SHA1.hexdigest(url)
  end
end
