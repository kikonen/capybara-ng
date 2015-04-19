cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile

echo "cucumber - poltergeist"
xvfb-run -a export CAPYBARA_DRIVER=poltergeist && bundle exec cucumber
EXIT_1=$?

echo "cucumber - webkit"
xvfb-run -a export CAPYBARA_DRIVER=webkit && bundle exec cucumber
EXIT_2=$?

echo "rspec - poltergeist"
xvfb-run -a export CAPYBARA_DRIVER=poltergeist && bundle exec rspec
EXIT_3=$?

echo "rspec - webkit"
xvfb-run -a export CAPYBARA_DRIVER=webkit && bundle exec rspec
EXIT_4=$?

if [[ $EXIT_1 != 0 || $EXIT_2 != 0 || $EXIT_3 != 0 || $EXIT_4 != 0 ]]; then
    echo "Failed"
    exit 1
fi
