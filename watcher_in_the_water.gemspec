Gem::Specification.new do |s|
  s.name = %q{watcher_in_the_water}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phil Hagelberg"]
  s.date = %q{2008-09-06}
  s.default_executable = %q{watcher_in_the_water}
  s.email = ["http://technomancy.us"]
  s.executables = ["watcher_in_the_water"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/watcher_in_the_water", "lib/watcher_in_the_water.rb", "test/fixtures/dimrill_gate", "test/fixtures/durins_bridge", "test/fixtures/west_gate", "test/live.yml", "test/live_test.rb", "test/test_watcher_in_the_water.rb", "test/watcher/test.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://en.wikipedia.org/wiki/Watcher_in_the_Water}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{watcher_in_the_water}
  s.rubygems_version = %q{1.2.0}
  s.summary = nil
  s.test_files = ["test/test_watcher_in_the_water.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<xmpp4r>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<xmpp4r>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<xmpp4r>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end