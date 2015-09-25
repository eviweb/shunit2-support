# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

### [Unreleased][unreleased]

#### Added
- new `-l` option to create library files under ./src


### 0.2.0 - 2015-09-24
#### Removed
- the provided $DIR variable from header template

#### Changed
- rely on $BASH_SOURCE instead of $0 in most of the scripts
- test suite runner now excludes directories named fixtures from test file gathering

#### Added
- a set of support functions in the header template
- generated test files and test suite are tagged with the current version
- test file and test suite updater

### 0.1.1 - 2015-09-22
#### Added
- test suite template
- test files
- sshunit2 now has a `-s` flag to create a test suite runner

### 0.1.0 - 2015-09-22
#### Added
- sshunit2 command
- header and footer templates for unit test generation
- test files
