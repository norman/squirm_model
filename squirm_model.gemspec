require File.expand_path("../lib/squirm/model/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "squirm_model"
  s.version       = Squirm::Model::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Norman Clarke"]
  s.email         = ["norman@njclarke.com"]
  s.homepage      = "http://github.com/bvision/squirm_model"
  s.summary       = %q{"An anti-ORM for database-loving programmers"}
  s.description   = %q{"Squirm is an anti-ORM for database-loving programmers"}
  s.bindir        = "bin"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 1.9"

  s.add_development_dependency "minitest", ">= 2.6"
  s.add_runtime_dependency "squirm", "> 0.0.0"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "activemodel"

  s.add_runtime_dependency "ambry", "~> 0.2.2"

end
