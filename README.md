# ReaTeam JSFX Repository

Community-maintained collection of JS effects for REAPER

[![Build Status](https://travis-ci.org/ReaTeam/JSFX.svg?branch=master)](https://travis-ci.org/ReaTeam/JSFX)

## Contributing

Fork this repository, add your JS effect(s) in an appropriate category (directory)
and send a pull request here.

Example of a basic JSFX package (the main files must have the `.jsfx` extension):

```c
/*
 * @version 1.0
 * @author John Doe
 * @changelog
 *   - Added super cool feature XYZ
 *   - Removed unused triggers
 */

desc:Description for REAPER

@init

@slider

@block

@sample
```

[List of supported metadata tags](https://github.com/cfillion/reapack-index#packaging-documentation)
