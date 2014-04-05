require 'url_watcher/url_fetcher'

module UrlWatcher

  # manages ONE url.
  # it compares the previous version with the current version of the page and sends out alerts
  class UrlChecker
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
      @filename ||= "#{XDG['DATA_HOME']}/#{APP_DIR}}/" + url_transform(url)
    end

    def check
      if File.exist?(filename)
        old_content = File.read(filename)
        unless old_content == content
          changed!
          save!
        end
      else
        save!
        alert_new!
      end
    end

    def alert_changed!(diff = nil)
      notifier.mail(
        "#{url} changed",
        "Hi there,\n\nJust writing you to say that [#{name}](#{url}) got updated.\n\nBye!\n",
        attachments: { "page.html" => content, 'diff' => diff })
    end

    def alert_new!
      notifier.mail(
        "Watching #{name} for you!",
        "Watching [#{name}](#{url}) for you!",
        attachments: { "page.html" => content })
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
