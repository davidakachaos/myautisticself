source "https://rubygems.org"

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
# gem "jekyll", "~> 3.8.5"

# This is the default theme for new Jekyll sites. You may change this to anything you like.
# gem "minima", "~> 2.0"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed"
  # gem "github-pages"
  gem 'jekyll-compose'
  gem 'jekyll-seo-tag'
  gem 'jemoji'
  gem 'jekyll-email-protect'
  gem 'jekyll-webmention_io', path: '../jekyll-webmention_io/' #github: 'davidakachaos/jekyll-webmention_io', branch: 'upgrade_webmention'
  gem 'jekyll-redirect-from'
  gem 'jekyll-responsive-image' #, path: '../jekyll-responsive-image/'
  gem 'amp-jekyll', path: '../amp-jekyll/'
  gem 'jekyll-pingback', path: '../jekyll-pingback/'
  gem 'jekyll-auto-image'
  gem 'jekyll-twitter-plugin'
  gem 'jekyll-tagging', path: '../jekyll-tagging'
  gem 'jekyll-last-modified-at'
  gem 'jekyll-mentions'
  gem 'jekyll-webp'
  gem 'jekyll-include-cache'
  gem 'jekyll-news-sitemap'
end

# Force WebP plugin needs this
gem 'mime-types', '~> 3.2.2', '>=3.0.0'

gem "jekyll", "~> 4.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.0" if Gem.win_platform?

# Fix security issue
gem "yard", ">= 0.9.20"
gem "activesupport", ">= 4.1.11"

#for amp generation
gem 'nokogiri'
gem 'fastimage'
gem 'html-proofer'
gem 'parallel'
gem 'faraday', '0.9.2'

gem "image_optim", "~> 0.26.5"
gem "image_optim_pack", "~> 0.6.0"

# better ruby
gem 'rubocop'
