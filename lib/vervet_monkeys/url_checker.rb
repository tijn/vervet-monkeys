require 'digest/sha1'
require 'fileutils'
require 'vervet_monkeys/url_fetcher'

module VervetMonkeys

  # manages ONE url.
  # it compares the previous version with the current version of the page and sends out alerts
  class UrlChecker
    include HTMLDiff
    attr_accessor :url, :options, :name, :notifier

    def initialize(url, notifier, options = {})
      @url = url
      @notifier = notifier
      @options = options
      @name = @options[:name] || url
    end

    def content
      @content ||= UrlFetcher.new(url, options).content
    end

    def hash
      @hash ||= Digest::SHA1.hexdigest(content)
    end

    def filename
      @filename ||= DATA_DIR + url_transform(url)
    end

    def check
      if File.exist?(filename)
        old_content = File.read(filename)
        unless old_content == content
          alert_changed!(diff(old_content, content))
          save!
        end
      else
        save!
        alert_new!
      end
    end

    def alert_changed!(diff = nil)
      notifier.notify_changed(name, url, content, diff)
    end

    def alert_new!
      notifier.notify_new(name, url, content)
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
