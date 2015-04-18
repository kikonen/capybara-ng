cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile
bundle install

bundle exec cucumber
bundle exec rspec
