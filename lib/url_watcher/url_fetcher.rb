module UrlWatcher

  # grabs a page
  #  or a part of a page
  class UrlFetcher
    attr_reader :url, :options

    def initialize(url, options = {})
      @url = url
      @options = options
    end

    def content
      response = fetch
      if options[:css]
        doc = Nokogiri::HTML(response)
        doc.css(options[:css]).map { |node| node.to_s.strip }.join("\n\n")
      end
    end

    def fetch
      open(url).read
    end
  end

end
