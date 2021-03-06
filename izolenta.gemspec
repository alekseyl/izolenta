# frozen_string_literal: true

require_relative "lib/izolenta/version"

Gem::Specification.new do |spec|
  spec.name          = "izolenta"
  spec.version       = Izolenta::VERSION
  spec.authors       = ["alekseyl"]
  spec.email         = ["leshchuk@gmail.com"]

  spec.summary       = "Migration helpers for delegated uniqueness in Postgres"
  spec.description   = "Migration helpers for delegated uniqueness in Postgres"
  spec.homepage      = "https://github.com/alekseyl/izolenta"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alekseyl/izolenta"
  spec.metadata["changelog_uri"] = "https://github.com/alekseyl/izolenta/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("pg")
  spec.add_development_dependency("activerecord", ">= 5")
  spec.add_development_dependency("rubocop-shopify")
  spec.add_development_dependency("ruby_jard")
end
