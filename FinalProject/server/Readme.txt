# install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install anaconda3
brew cask install anaconda

# install MongoDB
brew install mongodb

To have launchd start mongodb now and restart at login:
  brew services start mongodb
Or, if you don't want/need a background service you can just run:
  mongod --config /usr/local/etc/mongod.conf

# mslc environment
conda create --name mslc scipy numpy matplotlib tornado scikit-learn pymongo

source activate mslc

source deactivate mslc

# OpenML
pip install coremltools