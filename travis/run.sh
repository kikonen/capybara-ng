cd spec/dummy
export GEM_FILE=$PWF/Gemfile
bundle install

bundle exec cucumber
bundle exec rspec
