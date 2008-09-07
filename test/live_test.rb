require 'rubygems'
begin; gem 'miniunit'; rescue LoadError; end
require 'test/unit'
require 'mongrel'
require File.dirname(__FILE__) + '/../lib/watcher_in_the_water'

# launch Mongrel
class LiveServer < Mongrel::HttpHandler
  attr_accessor :string
  def process(request, response)
    response.start(200) do |head,out|
      out.write(@string || "hello!\n")
    end
  end
end

MONGREL = Mongrel::HttpServer.new("0.0.0.0", "3000")
MONGREL.register("/test", SimpleHandler.new)
MONGREL.run

class LiveTest < Test::Unit::TestCase
  def setup
    WatcherInTheWater.configure(File.dirname(__FILE__) + '/live.yml')
  end

  def test_live_usage
    # should alert about all pages being watched on first run
    # then should alert for a single change
    # then should send no alerts if nothing's changed
  end

  def test_host_not_found
  end

  def test_404
  end

  def test_sender_jabber_down
  end

  def test_bad_auth
  end

  def test_recipient_jabber_down
  end

  def test_recipient_jid_not_found
  end

  private
  def watch
    system "#{File.dirname(__FILE__)}/../bin/watcher #{File.dirname(__FILE__)}/live.yml"
  end
end
