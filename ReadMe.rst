GIT Versioning
==============
:Created: 2015-04-19
:Updated: 2016-06-16
:Version: 0.1.3-dev
:Status: Release
:project:

  .. image:: https://secure.travis-ci.org/dotmpe/git-versioning.png
    :target: https://travis-ci.org/dotmpe/git-versioning
    :alt: Build

:repository:

  .. image:: https://badge.fury.io/gh/dotmpe%2Fgit-versioning.png
    :target: http://badge.fury.io/gh/dotmpe%2Fgit-versioning
    :alt: GIT


.. admonition:: Features

   - Update embedded semver strings and Ids in project files, increment and
     tag programatically, or synchronize from ReadMe version field.

   - Darwin BSD and \*nix GNU sed compatible rewrites.
     Rewrites available for comments and variables in Makefile, Ant, Shell
     script, JavaScript, Coffee-Script, reStructuredText, JSON and YAML.

   - Easily add formats with unix, C or XML (line) comments.

   - Example comment and variable declaration with full semver string::

         # Id: application-name/1.0.0-alpha+exp.sha.5114f85 path/to/source.ext

         version="1.0.0-alpha+exp.sha.5114f85"; # application-name


.. admonition:: Quickstart

   Install ::

     $ make install

   or::

     @ENV=production ./configure.sh /usr/local
     @ENV=production sudo ./install.sh uninstall

   See also Travis CI test build script.

   Use::

     cd myproject
     echo my-project > .app-id
     echo :Version: 0.0.1  > ReadMe.rst
     echo "# Id: my-project" > test.sh
     echo 'version=0.0.1 # my-project' >> test.sh
     echo -e '{\n"version":"0.0.1"\n}' > package.json
     echo ReadMe.rst > .versioned-files.list
     echo package.json >> .versioned-files.lst
     echo test.sh >> .versioned-files.lst
     git-versioning dev
     git-versioning snapshot
     git-versioning update
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

.. rSt example:
.. Id: git-versioning/0.1.3-dev ReadMe.rst


Other documents
---------------
- `Development documentation <doc/dev.rst>`_
- `Initial analysis (ReadMe) <doc/initial-analysis.rst>`_
- `Change Log <ChangeLog.rst>`_
- `Branche and Directory Docs <doc/package.rst>`_


.. ----

.. _sitefile: http://github.com/dotmpe/node-sitefile

.. Id: git-versioning/0.1.3-dev ReadMe.rst
