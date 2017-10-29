
``git-versioning`` uses a ``case/esac`` expression to dispatch to shell
functions reading version lines, and another for applying. Matching will stop
on the first line,

Write formats
-------------
Filetypes that git-versioning can read the version from::

    *.md
    *.rst
    *.mk | *Makefile*
    *.sh | *.bash | *configure | *.bats

Output formats
--------------
Filetypes that git-versioning writes to::

  *.rst
  *.sitefilerc
  *Sitefile*.yaml | *Sitefile*.yml
  *.mk | */Makefile | Makefile
  *.sh | *.bash | configure | */configure | *.bats
  *.yaml | *.yml
  *.json
  *.js
  *.coffee | *.go
  *.py
  *.properties
  *build.xml
  *.xml
  *.pde | *.ino | *.c | *.cpp | *.h
  *.pug | *.styl | *.pde | *.ino | *.c | *.cpp | *.h | *.java | *.groovy
  Dockerfile | */Dockerfile
