Shunit2 Support
===============
this little lib aims to help in managing [shunit2](https://github.com/kward/shunit2) in your project.    

##### Health status
[![Travis CI - Build Status](https://travis-ci.org/eviweb/shunit2-support.svg)](https://travis-ci.org/eviweb/shunit2-support)
[![Github - Last tag](https://img.shields.io/github/tag/eviweb/shunit2-support.svg)](https://github.com/eviweb/shunit2-support/tags)

Installation
------------
* clone this repository `git clone --recursive https://github.com/eviweb/shunit2-support.git`
* run the installer `shunit2-support/install.sh`    
_this will create a link to the `shunit2-support/src/sshunit2` command in your `$HOME/bin` directory_   

> _Please note that if the `$HOME/bin` does not exist, it will be created.   
> In this case you will need to refresh your environment. (ie. by running `exec bash -l`)_

**To remove the `sshunit2` command:** run the installer with the `-u` flag: `shunit2-support/install.sh -u`   

Usage
-----
* `sshunit2 -p /path/to/project`: create a new project with shunit2 support enabled
* `sshunit2 -t command_name` (*): generate a unit test file for a given command
* `sshunit2 -i`: enable shunit2 support in the current directory
* `sshunit2 -c filename` (*): create a command file relatively under `./src`
* `sshunit2 -l filename` (*): create a library file relatively under `./src`
* `sshunit2 -s` (*): generate a test suite runner under `./tests`
* `sshunit2 -U file_or_dir`: update old unit test and test suite files with new version templates
* `sshunit2 -h`: display the help message  

> _(*) Please note that these command calls must be run from within your project directory_   
  

License
-------
this project is licensed under the terms of the [MIT License](/LICENSE)