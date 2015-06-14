git-versioning:

  has a CLI component, which:
    - by default should report a short usage description followed by non-zero exit
    - should be able to report its own version
    - should be able to report on the version of the current project
    - should be able to update files with embedded versions

  has a Bash library, which:



  - uses semver versions and understands the parts
  - understands various single line embedded version formats
    for detecting proper data and updating.

    - Makefile
    - Bash
    - Python
    - JavaScript
    - CoffeeScript
    - PHP

  - FIXME: should try to write scanner that uses pattern/template combos
    which does not need to know about file format.


