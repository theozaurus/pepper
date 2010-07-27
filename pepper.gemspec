# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pepper}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Theo Cushion"]
  s.date = %q{2010-07-27}
  s.description = %q{Currently supports connecting to Nominet and running checks on domain names}
  s.email = %q{theo@triplegeek.com}
  s.files = ["README", "lib/pepper", "lib/pepper/commands.rb", "lib/pepper/connection.rb", "lib/pepper/error.rb", "lib/pepper/stanzas", "lib/pepper/stanzas/account_addr.rb", "lib/pepper/stanzas/account_infdata.rb", "lib/pepper/stanzas/chkdata.rb", "lib/pepper/stanzas/contact_infdata.rb", "lib/pepper/stanzas/domain_infdata.rb", "lib/pepper/stanzas/epp.rb", "lib/pepper/stanzas/host.rb", "lib/pepper/stanzas/ns.rb", "lib/pepper/stanzas/resdata.rb", "lib/pepper/stanzas/response.rb", "lib/pepper/stanzas/result.rb", "lib/pepper/stanzas/sax_machinery.rb", "lib/pepper/stanzas.rb", "lib/pepper/stream_parser.rb", "lib/pepper.rb", "test/fixtures/login_success.xml", "test/live_pepper_test.rb", "test/pepper_test.rb", "test/test_helper.rb", "test/live_settings.yaml.example"]
  s.homepage = %q{http://github.com/theoooo/pepper}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Provides a simple interface to Nominets EPP service}
  s.test_files = ["test/fixtures/login_success.xml", "test/live_pepper_test.rb", "test/pepper_test.rb", "test/test_helper.rb", "test/live_settings.yaml.example"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sax-machine>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<sax-machine>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<sax-machine>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end
