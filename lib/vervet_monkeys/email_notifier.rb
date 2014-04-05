module VervetMonkeys

  class EmailNotifier
    MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    def self.config(options = {})
      Pony.options = {from: "url-watcher@#{`hostname`}}"}.merge(options)
      # { :from => 'noreply@example.com', :via => :smtp, :via_options => { :host => 'smtp.yourserver.com' } }
    end

    def self.puts(*strings)
      subject = strings.shift
      strings.each do |string|
        mail(subject, strings.join("\n\n"))
      end
    end

    def self.mail(subject, body, options = {})
      attachments = (options[:attachments] || {}).reject {|k,v| v.nil? }
      Pony.mail(
        subject: subject,
        body: body,
        html_body: MARKDOWN.render(body),
        attachments: attachments)
    end

  end

end
