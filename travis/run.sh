cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile

bundle exec cucumber
EXIT_1=$?

bundle exec rspec
EXIT_2=$?

if [[ $EXIT_1 != 0 || $EXIT_2 != 0]]; then
    exit 1
fi
