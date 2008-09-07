require 'rubygems'
begin; gem 'miniunit'; rescue LoadError; end
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/watcher_in_the_water'

module WatcherInTheWater
  # Let's mock out the Jabber connection
  @client = Object.new
  @messages = []
  messages_for_closure = @messages

  def @client.send(message)
    WatcherInTheWater.messages << message
  end

  def self.messages; @messages; end
  def self.config; @config; end
end

WatcherInTheWater.configure(File.dirname(__FILE__) + '/watcher/test.yml')

class TestWatcherInTheWater < Test::Unit::TestCase
  def setup
    FileUtils.rm_rf('hashes')
    FileUtils.rm_rf('fixtures')
    FileUtils.cp_r('../fixtures', 'fixtures')
    WatcherInTheWater.messages.clear
  end

  def test_watch_first_time
    WatcherInTheWater.watch

    ['fixtures_dimrill_gate_d2785ed5a8c89b47e541e85b7216d0153a383651',
     'fixtures_durins_bridge_f81c948ae30baa391371150bc42cc935ebf8287c',
     'fixtures_west_gate_cdef5d9283f6bdeddfa89de21bbca8d5acb3c673'].each do |u|
      assert_equal 40, File.read('hashes/' + u).length
    end

    assert_equal 3, WatcherInTheWater.messages.size
  end

  def test_watch_one_change
    WatcherInTheWater.watch
    WatcherInTheWater.messages.clear

    File.open('fixtures/durins_bridge', 'w') { |f| f.puts "Durin's Super-Bridge!" }
    WatcherInTheWater.watch

    assert_equal 1, WatcherInTheWater.messages.size
  end

  def test_watch_no_changes
    WatcherInTheWater.watch
    WatcherInTheWater.messages.clear

    WatcherInTheWater.watch

    assert_equal [], WatcherInTheWater.messages
  end
end
