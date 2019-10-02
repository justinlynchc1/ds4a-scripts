#!/usr/bin/env bash

BASH_CONFIG="$HOME/.bash_profile"
HOMEBREW_VERSION="2.1.11"
PYTHON_VERSION="3.7.4"
VIRTUAL_ENV_VERSION="16.7.5"
DEPENDENCIES='jupyter numpy scipy matplotlib ipython[all] pandas seaborn branca geopandas folium wordcloud'

function install_dependencies () {
 echo "Installing Other Dependencies: " | tr -d '\n' >&2;
 for DEPENDENCY in $DEPENDENCIES
 do
   pip install $DEPENDENCY
 done
 echo "...DONE";
}

function get_os () {
  case "$OSTYPE" in
    darwin*)  echo "OSX" ;; 
    msys*)    echo "WINDOWS" ;;
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD" ;;
    solaris*) echo "SOLARIS" ;;
    *)        echo "OTHER" ;;
  esac
}

function required_for_osx () {
  command -v xcode-select >/dev/null 2>&1 && echo "XCode (CLT) already installed" || {
    echo "Missing XCode (CLT)...Installing..." && xcode-select --install;
  }
  if [[ "$(brew -v 2>&1 | head -n 1)" == "Homebrew $HOMEBREW_VERSION" ]]; then
    echo "$(brew -v 2>&1 | head -n 1) already installed."
  else 
    command -v brew >/dev/null 2>&1 && ( echo "Found Homebrew...Updating..." && brew update ) || {
      echo "Missing Hombrew...Installing..." && /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
    }
  fi
  if [[ "$(python -V)" == "Python $PYTHON_VERSION" ]]; then
    echo "$(python -V) already installed"
  else 
    command -v python >/dev/null 2>&1 && ( echo "Found Python...Updating..." && brew upgrade python ) || {
      echo "Missing Python...Installing..." && brew install python && update_bash_config;
    }
  fi
  if [[ "$(virtualenv --version)" == "$VIRTUAL_ENV_VERSION" ]]; then
    echo "virtualenv $(virtualenv --version) already installed.";
    [ -d "venv" ] && ( echo "venv already exists. Activating..." && source venv/bin/activate ) || ( echo "Making..." && virtualenv venv && echo "Activating..." && source venv/bin/activate )
  else 
    echo "Missing virtualenv...Installing..." && pip install virtualenv==16.7.5 && virtualenv venv && echo "Activating..." && source venv/bin/activate
  fi
  source $PWD/venv/bin/activate;
}


function update_bash_config () {
  touch $BASH_CONFIG;
  echo 'export PATH=/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH' >>$BASH_CONFIG;
  echo 'alias python="python3"' >>$BASH_CONFIG;
  echo 'alias pip="pip3"' >>$BASH_CONFIG;
  echo 'alias python2="\python"' >>$BASH_CONFIG;
  source $BASH_CONFIG;
}

function steps_for_osx () {
  echo "Setting up Mac env";
  required_for_osx
}

function steps_for_windows () {
  echo "Setting up Windows env...";
}

function steps_for_others () {
  echo "Ignoring Other OS for now...Sorry!";
}

function start_setup () {
  OS=$(get_os)
  if [[ "$OS" == "OSX" ]]; then
    steps_for_osx
  elif [["$OS"=="WINDOWS"]]; then
    steps_for_windows
  else
    steps_for_others
  fi
}

start_setup