cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile

xvfb-run -a bundle exec cucumber
EXIT_1=$?

xvfb-run -a bundle exec rspec
EXIT_2=$?

if [[ $EXIT_1 != 0 || $EXIT_2 != 0 ]]; then
    echo "Failed"
    exit 1
fi
