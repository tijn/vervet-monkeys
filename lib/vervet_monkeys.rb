require 'vervet_monkeys/monkey'

module VervetMonkeys
  HELP = <<-end_help
The settings should look like this:

---
email:
  :via: sendmail
  :to: me-myself-and-i@example.com
  :from: url-watcher@example.com

Don't forget the colons in front of the settings, they are important!
end_help

  VERSION = '1.0'
  APP_DIR = 'vervet-monkeys'

  CONFIG_DIR = "#{XDG['CONFIG_HOME']}/#{APP_DIR}/"
  DATA_DIR = "#{XDG['DATA_HOME']}/#{APP_DIR}}/"
end
