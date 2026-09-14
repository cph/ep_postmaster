source "https://rubygems.org"

# Declare your gem's dependencies in ep_postmaster.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# json 3.0 made JSON.parse options keyword-only, which breaks
# ActiveSupport::JSON.decode (as of Rails 8.1.3.1); remove once Rails supports json 3
gem "json", "< 3"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
