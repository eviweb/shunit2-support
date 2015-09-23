Shunit2 Support
===============
this little lib aims to help in managing [shunit2](https://github.com/kward/shunit2) in your project.    

Installation
------------
* clone this repository `git clone --recursive https://github.com/eviweb/shunit2-support.git`
* run the installer `shunit2-support/install.sh`    
_this will create a link to the `shunit2-support/src/sshunit2` command in your `$HOME/bin` directory_   

> _Please note that if the `$HOME/bin` does not exist, it will be created.   
> In this case you will need to refresh your environment. (ie. by running `exec bash -l`)_

**To remove the `sshunit2` command:** run the installer with the `-u` flag: `shunit2-support/install.sh -u`   

The command
-----------
### create a new project with shunit2 support enabled
run `sshunit2 -p /path/to/project`    
### generate a unit test file for a given command
run `sshunit2 -t command_name`    

> _Please note that the current directory must be your project directory_   

### enable shunit2 support in an existing project directory
run `sshunit2 -i`    

> _Please note that the current directory must be your project directory_   

### generate a test suite runner under _./tests_ directory
run `sshunit2 -s`    

### update old unit test files with new version templates
run `sshunit2 -U file_or_dir`    

### display the help message
run `sshunit2 -h`    

License
-------
please see [LICENSE](/LICENSE)