#!/usr/bin/env ruby

require "rubygems"
require 'bundler/setup'
Bundler.require

require 'open-uri'
require 'yaml'
require 'digest/sha1'
require 'fileutils'
require 'url_watcher/url_checker'
require 'url_watcher/email_notifier'

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
    # include Jabber

    def initialize(config_file = nil)
      config_file ||= "#{config_dir}/config.yml"
      filename = File.expand_path(config_file)
      @config = YAML.load_file(filename)
      EmailNotifier.config(@config['email'])
    rescue
      abort HELP.gsub("{{config}}", filename)
    end

    def url_configs
      @url_configs ||= load_url_configs
    end

    def watch
      url_configs.each { |url_config| watch_url(url_config) }
    end

    def watch_url(url)
      UrlChecker.new(url['url'], EmailNotifier, css: url['css'], name: url['name']).check
    end

    def load_url_configs
      Dir.glob("#{config_dir}/urls/*.yml").map do |filename|
        YAML.load_file(filename)
      end
    end

    def config_dir
      "#{XDG['CONFIG_HOME']}/#{APP_DIR}/"
    end
  end


end
