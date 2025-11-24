# frozen_string_literal: true

require_relative "lib/nuhttp/version"

Gem::Specification.new do |spec|
  spec.name = "nuhttp"
  spec.version = NuHttp::VERSION
  spec.authors = ["Daisuke Aritomo"]
  spec.email = ["osyoyu@osyoyu.com"]

  spec.summary = "A new HTTP server framework for Ruby."
  spec.homepage = "https://github.com/osyoyu/nuhttp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/osyoyu/nuhttp"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_development_dependency "herb"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rbs-inline"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
