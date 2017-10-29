GIT Versioning
==============
:Created: 2015-04-19
:Updated: 2017-10-29
:Version: 0.2.9
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

See `manual <doc/manual.rst>`_.

Other documents
---------------
For issues, see `dev docs <doc/dev.rst#issues>`__

- `Change Log <ChangeLog.rst>`_
- `Development documentation <doc/dev.rst>`_
- `Initial analysis (ReadMe) <doc/initial-analysis.rst>`_
- `Branche and Directory Docs <doc/package.rst>`_


Builds
------
Latest releases are available at github__, stability of SCM editions can be
examined at Travis__.

FIXME: Building the tar distributable is left to a Mkdocs (Makefile) setup, but
its use it not tested at all! (src may be out of date?) The package is
prepared by Travis on tagged commits, from the 'production' build env.

However, installations of a development, testing, and production flavoured
configuration from SCM are tested.

TODO: add & test basher install


.. __: https://github.com/bvberkum/git-versioning/releases
.. __: https://travis-ci.org/bvberkum/git-versioning/branches


.. ----

.. _sitefile: http://github.com/bvberkum/node-sitefile

.. Id: git-versioning/0.2.9 ReadMe.rst
