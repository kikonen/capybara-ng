echo "================================"
ls -al vendor/bundle
echo "================================"

cd spec/dummy

export BUNDLE_GEMFILE=$PWD/Gemfile
bundle install

echo "================================"
ls -al vendor/bundle
echo "================================"
