cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile

#
# CUCUMBER
#
echo "cucumber - poltergeist"
xvfb-run -a export CAPYBARA_DRIVER=poltergeist && bundle exec cucumber
EXIT_1_1=$?

echo "cucumber - webkit"
xvfb-run -a export CAPYBARA_DRIVER=webkit && bundle exec cucumber
EXIT_1_2=$?

echo "cucumber - selenium"
xvfb-run -a export CAPYBARA_DRIVER=selenium && bundle exec cucumber
EXIT_1_3=$?

#
# RSPEC
#
echo "rspec - poltergeist"
xvfb-run -a export CAPYBARA_DRIVER=poltergeist && bundle exec rspec
EXIT_2_1=$?

echo "rspec - webkit"
xvfb-run -a export CAPYBARA_DRIVER=webkit && bundle exec rspec
EXIT_2_2=$?

echo "rspec - selenium"
xvfb-run -a export CAPYBARA_DRIVER=selenium && bundle exec rspec
EXIT_2_3=$?

#
# Exit check
#
if [[ $EXIT_1_1 != 0 || $EXIT_1_2 != 0 || $EXIT_1_3 != 0 ]]; then
    echo "Cucumber Failed"
    exit 1
fi

if [[ $EXIT_2_1 != 0 || $EXIT_2_2 != 0 || $EXIT_2_3 != 0 ]]; then
    echo "Rspec Failed"
    exit 1
fi
