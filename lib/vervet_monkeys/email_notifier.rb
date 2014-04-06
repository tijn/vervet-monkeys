module VervetMonkeys

  class EmailNotifier
    MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    def self.config(options = {})
      Pony.options = {from: "url-watcher@#{`hostname`}}"}.merge(options)
      # { :from => 'noreply@example.com', :via => :smtp, :via_options => { :host => 'smtp.yourserver.com' } }
    end

    def self.notify_changed(name, url, content, diff)
        body = "Hi there,\n\nJust writing you to say that [#{name}](#{url}) got updated.\n\nBye!\n"
        html_body = MARKDOWN.render(body)
        if diff
          html_body << "\n\n" << diff
        end

        Pony.mail(
          subject: "#{url} changed",
          body: body,
          html_body: html_body,
          attachments: { "page.html" => content, 'diff' => diff })
    end

    def self.notify_new(name, url, content)
      body = "Watching [#{name}](#{url}) for you!"
      html_body = MARKDOWN.render body

      Pony.mail(
        subject: "Watching #{name} for you!",
        body: body,
        html_body: html_body,
        attachments: { "page.html" => content })
    end

    def self.mail(subject, body, options = {})
      attachments = (options[:attachments] || {}).reject {|k,v| v.nil? }

      html_body = MARKDOWN.render(body)
      if options[:diff]
        html_body << "\n\n" << options[:diff]
      end

      Pony.mail(
        subject: subject,
        body: body,
        html_body: html_body,
        attachments: attachments)
    end

  end

end
