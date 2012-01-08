# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-lotto"
  s.version     = "0.0.1" 
  s.authors     = ["rakusu"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Siri controlled lottery}
  s.description = %q{Ask Siri what the number lotteries are}

  s.rubyforge_project = "siriproxy-lotto"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "httparty"
end

