#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'yaml'
require 'digest/sha1'
require 'xmpp4r'
require 'fileutils'

module WatcherInTheWater
  include Jabber
  VERSION = '0.1'

  module_function

  def configure(config = nil)
    config = File.expand_path(config || '~/.watcher/config.yml')
    FileUtils.cd(File.dirname(config))
    @config = YAML.load(File.read(config))
  rescue
    abort "You need #{config} to contain a sender jabber ID, password,
a recipient jabber ID, and a list of URLs in YAML format. Example:

---
jid: watcher-in-the-water@jabber.org
password: mellon
recipient: phil@hagelb.org
urls: ---
  http://rubyconf.org
"
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

  def alert(mess)
    connect
    @client.send Message.new(@config['to'], mess).set_type(:normal).set_id('1')
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
