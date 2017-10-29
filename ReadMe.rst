GIT Versioning
==============
:Created: 2015-04-19
:Updated: 2017-10-29
:Version: 0.3.0-dev+golang
:project:

  .. image:: https://secure.travis-ci.org/bvberkum/git-versioning.png
    :target: https://travis-ci.org/bvberkum/git-versioning
    :alt: Build

:repository:

  .. image:: https://badge.fury.io/gh/bvberkum%2Fgit-versioning.png
    :target: http://badge.fury.io/gh/bvberkum%2Fgit-versioning
    :alt: GIT


.. image:: media/image/git-versioning-hook.png

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

See `manual <doc/manual.rst>`_ and `development documentation <doc/dev.rst>`_.
For issues, see `dev docs <doc/dev.rst#issues>`__ too.

Builds
------
Latest releases are available at github__, stability of SCM editions can be
examined at Travis__.

TODO: add & test basher install


.. __: https://github.com/bvberkum/git-versioning/releases
.. __: https://travis-ci.org/bvberkum/git-versioning/branches

.. ----

.. _sitefile: http://github.com/bvberkum/node-sitefile

.. Id: git-versioning/0.2.10-dev ReadMe.rst
