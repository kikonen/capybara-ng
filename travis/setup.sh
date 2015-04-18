echo "================================"
ls -al vendor
echo "================================"

cd spec/dummy

echo "================================"
export
echo "================================"
env
echo "================================"

export BUNDLE_GEMFILE=$PWD/Gemfile
bundle install

echo "================================"
ls -al vendor
echo "================================"
