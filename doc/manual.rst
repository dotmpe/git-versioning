Install ::

  $ make install
  $ make uninstall

or::

  @ENV_NAME=production ./configure.sh /usr/local
  @ENV_NAME=production sudo ./install.sh uninstall
  @ENV_NAME=production sudo ./install.sh install


See also Travis CI test build script.


Two options per project

1. .versioned-files.list file, starting with the main-document and followed
   by other files::

      cd myproject
      echo my-project > .app-id
      echo :Version: 0.0.1  > ReadMe.rst
      echo "# Id: my-project" > test.sh
      echo 'version=0.0.1 # my-project' >> test.sh
      echo -e '{\n"version":"0.0.1"\n}' > package.json
      echo ReadMe.rst > .versioned-files.list
      echo package.json >> .versioned-files.lst
      echo test.sh >> .versioned-files.lst


2. .version-attributes to customize main-document, list-file, and other
   settings::

      App-Id: git-versioning
      # Version:
      Main-File: ReadMe.rst
      # Formats: /src/github.com/bvberkum/git-versioning/lib/formats.sh
      # Local-Formats: local-formats.sh
      # File-List: .versioned-files.list
      # Other-Files:

::

  git-versioning check # verify all versions match
  git-versioning dev # apply dev tag
  git-versioning snapshot # apply feature tag
  git-versioning update #
  git-versioning check


Syntax
------
For clike or hash-comment languages::

  # Id: app-id/0.0.0 path/filename.ext
  # version: 0.0.0 app-id path/filename.ext

And while the exact format differs they follow the pattern::

  version = 0.0.0 # app-id

For some files exceptions are made. Refer to test/example files for syntax
per format.

The app-id is included to avoid any ambiguity.
Exact specs of variable rewrites may differ per format since its not always
possible to include a comment on the line (ie. JSON).


rSt example::

  .. Id: git-versioning/0.2.0-dev ReadMe.rst


