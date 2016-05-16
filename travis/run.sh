cd spec/dummy
export BUNDLE_GEMFILE=$PWD/Gemfile

#
# CUCUMBER
#
echo "cucumber - poltergeist"
CAPYBARA_DRIVER=poltergeist xvfb-run -a bundle exec cucumber
EXIT_1_1=$?

echo "cucumber - webkit"
CAPYBARA_DRIVER=webkit xvfb-run -a bundle exec cucumber
EXIT_1_2=$?

echo "cucumber - selenium"
CAPYBARA_DRIVER=selenium xvfb-run -a bundle exec cucumber
EXIT_1_3=$?

#
# RSPEC
#
echo "rspec - poltergeist"
CAPYBARA_DRIVER=poltergeist xvfb-run -a bundle exec rspec
EXIT_2_1=$?

echo "rspec - webkit"
CAPYBARA_DRIVER=webkit xvfb-run -a bundle exec rspec
EXIT_2_2=$?

echo "rspec - selenium"
CAPYBARA_DRIVER=selenium xvfb-run -a bundle exec rspec
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
