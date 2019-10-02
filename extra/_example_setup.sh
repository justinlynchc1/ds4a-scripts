#!/usr/bin/env bash
function require_xcode_cli () {
 command -v xcode-select >/dev/null 2>&1 || {
   echo "Installing XCode cli..." | tr -d '\n' >&2;
   xcode-select --install;
   echo "DONE"
 }
}
function require_homebrew () {
 command -v brew >/dev/null 2>&1 || {
   echo "Installing Homebrew..." | tr -d '\n' >&2;
   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
   brew update;
   echo "DONE"
 }
}
function clean_up_current_python () {
 PROFILES='bash_login bash_profile cshrc profile tcshrc zprofile zshrc'
 INSTALLATIONS='python pip pyenv'
 echo "Removing Existing Local Python Installations: " | tr -d '\n' >&2;
 for INSTALLATION in $INSTALLATIONS
 do
   ls -l /usr/local/bin | grep $INSTALLATION | awk '{print "rm \47/usr/local/bin/" $9 "\47"}';
 done
 brew uninstall --ignore-dependencies python;
 echo "...DONE";
 echo "Removing aliases in profiles: ";
 for PROFILE in $PROFILES
 do
   FILE=$HOME/.$PROFILE
   if [ -f "$FILE" ]; then
     sed -i '/alias python/d' $FILE;
     sed -i '/alias pip/d' $FILE;
     sed -i '/virtualenv/d' $FILE;
     sed -i 'export PATH="/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH"' $FILE;
     echo "~/.$PROFILE, " | tr -d '\n' >&2;
   fi
 done
 rm -rf venv;
 echo "...DONE";
}
function install_python () {
 brew install python;
}
function install_and_make_virtualenv () {
 echo "Installing virtualenv";
 pip install virtualenv virtualenvwrapper;
 echo "Making virtualenv";
 virtualenv venv;
}
function activate_virtualenv () {
 echo 'source venv/bin/activate'>&1;
}
function install_dependencies () {
 DEPENDENCIES='jupyter numpy scipy matplotlib ipython[all] pandas seaborn'
 echo "Installing Other Dependencies: " | tr -d '\n' >&2;
 for DEPENDENCY in $DEPENDENCIES
 do
   pip install $DEPENDENCY
 done
 echo "...DONE";
}
function configure_python () {
 echo "Updating PATH in bash_profile: " | tr -d '\n' >&2;
 BASH_CONFIG="$HOME/.bash_profile"
 touch $BASH_CONFIG;
 echo 'export PATH=/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH' >>$BASH_CONFIG
 echo 'export WORKON_HOME=~/.virtualenvs' >>$BASH_CONFIG
 echo '[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh' >>$BASH_CONFIG
 echo 'alias python="python3"' >>$BASH_CONFIG
 echo 'alias python2="\python"' >>$BASH_CONFIG
 echo "...DONE";
 echo "Reloading profile: " | tr -d '\n' >&2;
 source $BASH_CONFIG;
}
function launch_notebook() {
 cd cases
 jupyter notebook
}
function main_setup () {
 echo ""
 echo "===================================="
 echo "Setting up local Mac OSX environment"
 echo "===================================="
 require_xcode_cli
 require_homebrew
 clean_up_current_python
 install_python
 configure_python
 install_and_make_virtualenv
 activate_virtualenv
 install_dependencies
 echo "DONE!"
 launch_notebook
}
main_setup