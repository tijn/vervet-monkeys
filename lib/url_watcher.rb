#!/usr/bin/env ruby

require "rubygems"
require 'bundler/setup'
Bundler.require

require 'open-uri'
require 'yaml'
require 'digest/sha1'
require 'fileutils'
require 'url_watcher/url_fetcher'

module UrlWatcher
  HELP = <<-end_help
You need {{config}} to contain a sender jabber ID, password,
a recipient jabber ID, and a list of URLs in YAML format. Example:

---
jid: url-watcher@jabber.org
password: mellon
recipient: phil@hagelb.org
urls: ---
  http://rubyconf.org
end_help
  VERSION = '1.0'
  APP_DIR = 'url-watcher'

  class Watcher
    include Jabber

    def initialize(config_file = nil)
      config_file ||= "#{config_dir}/config.yml"
      filename = File.expand_path(config_file)
      @config = YAML.load_file(filename)
    rescue
      abort HELP.gsub("{{config}}", filename)
    end

    def urls
      @urls ||= load_urls
    end

    def watch
      urls.each do |url|
        watch_url(url)
      end
    end

    def watch_url(url)
      UrlChecker.new(url['url'], jabber_client, css: url['css']).check
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

    def jabber_client
      # connect
      # @client
      STDOUT
    end

    def url_transform(url)
      url.gsub(/[^\w]/, '_')[0 .. 50] + '_' + Digest::SHA1.hexdigest(url)
    end

    def load_urls
      Dir.glob("#{config_dir}/urls/*.yml").map do |filename|
        YAML.load_file(filename)
      end
    end

    def config_dir
      "#{XDG['CONFIG_HOME']}/#{APP_DIR}/"
    end

  end


  class UrlChecker
    attr_accessor :url, :jabber, :options

    def initialize(url, jabber, options = {})
      @url = url
      @jabber = jabber
      @options = options
    end

    def content
      @content ||= UrlFetcher.new(url, options).content
    end

    def hash
      @hash ||= Digest::SHA1.hexdigest(content)
    end

    def filename
      @filename ||= "#{XDG['DATA_HOME']}/#{APP_DIR}}/" + url_transform(url)
    end

    def check
      if File.exist?(filename)
        unless File.read(filename) == content
          save!
          jabber.puts("#{url} changed") # to #{content[0 .. 200]}")
        end
      else
        save!
        jabber.puts("Watching #{url} for you!")
      end
    end

    def save!
      puts "saving #{filename}"
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, 'w') { |f| f.write content }
    end

    def url_transform(url)
      url.gsub(/[^\w]/, '_')[0 .. 50] + '_' + Digest::SHA1.hexdigest(url)
    end
  end
end
