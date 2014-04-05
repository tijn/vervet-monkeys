require 'yaml'
require 'vervet_monkeys/email_notifier'
require 'vervet_monkeys/url_checker'

module VervetMonkeys

  # Vervet monkeys are the typical example of both animal alarm calls and of
  # semantic capacity in non-human animals.
  # http://en.wikipedia.org/wiki/Alarm_signal#Monkeys_with_alarm_calls
  #
  # This monkey keeps an eye on each website you tell it about. It makes an
  # alarm call whenever it spots a change in one. (It thinks changes in
  # websites are highly suspicious and it knows how to send an alarming email.)
  class Monkey
    # include Jabber

    def initialize(config_file = nil)
      FileUtils.mkdir_p(CONFIG_DIR + '/urls')
      config_file ||= CONFIG_DIR + "config.yml"
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
      Dir.glob("#{CONFIG_DIR}/urls/*.yml").map do |filename|
        YAML.load_file(filename)
      end
    end

  end
end
