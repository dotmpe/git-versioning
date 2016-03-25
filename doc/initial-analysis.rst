Initial ReadMe
==============
:Created: 2015-04-19
:Updated: 2016-03-25
:Description: archived docs with some ToDo's to take up elsewhere.

.. contents::


Background
----------
Looking around for a GIT versioning hook it seemed mildy simple at first, but
some different scenarios and issues emerged.
What to commit, and when is not that predictable outside any CI environment.
Taken a step back, more common sense points are raised by semver2_. [#]_

The git hooks are therefore out of use. If the testing of supported formats
improves, that would be a good point to get into pre-commit checks again that
can fail if a commit/push would make a semver violation.

Semver makes a plead for stable, well-defined states of software that at
any point have a sensible patch- or upgrade-path. Stable in the sense of
code version, not of application stability per se.

Stable implies its state is well-defined: something documented, maybe
by use cases, requirements, test scenarios, or implicit in automatic tests
scripts, deployment environments etc. But that has become an entirely different
scope. There is still a section on GIT hooks below.


Semver summary
--------------
This use case builds on a `semver` ``MAJOR.MINOR.PATCH`` version specification.
Here is my breve extract of `Semantic Versioning 2.0.0`__.

.. __: semver2_

1. 0.x.y being development versions with unstable API
2. 1.0.0 being the first public API version
3. public API versions never have code changes
4. minor versions increase with backward compatible API changes
5. major versions increase with backward incompatible API changes
6. the version spec may further qualified by pre-release-version tags ``-[0-9A-Za-z-]\.``, these are considered in comparisons. Ie. so that ``1.0 != 1.0-dev``.
7. the spec may be amended by build metadata tags ``+[0-9A-Za-z-]\.`` without
   affecting the version qualifier, these should be ignored while comparing versions.

E.g.::

    1.0.0-alpha+exp.sha.5114f85

The nice thing about semver is it has a clear concept of publicity
and stability.
For one thing, there is no need to commit to a public version 1.0, giving a
clear indication a project may not be there yet--or maybe not intendend as such at all,
marking for sandboxed, experimental use which is a good thing in the global
code ecosphere.

Also, from this follows that any project metadata must hold some pre-release
version during development. This should uniquely identify the state wether in 0.x.y
or in post-1.0.0 range.

This way tags, commits, metadata, docs etc. always contain the appropiate version,
since there is and can never be ambigious source states.


Work flow
---------

Development
~~~~~~~~~~~
Before and during development:

1. Prep GIT project, amend and update ``.versioned-files.list``.
2. Write main doc (e.g. ``ReadMe.rst``) to contain start version and tags.
3. ``cli-version update`` update all other files with new version.
4. Commit changes under pre-release tagged versions until final package commit.
   And before publication (push) ``cli-version check``.
   See the next flows.

Packaging
~~~~~~~~~
For the increment, the level will need to be chosen.
Pre-release/Release-candidate tags etc. usually go, by some kinds of info may
move to the build-meta tags.

* ``cli-version increment [vmin [vmaj]]`` increment to new version (and discard version-tags).
* ``cli-version build|pre-release tags[..]`` mark version with given release or build tag(s) respectively, or rather to reset them for a proper release.

* ``cli-version dev|testing|unstable [tags..]`` shortcut to mark pre-release with tag 'dev', 'alpha' or 'beta' resp.
* ``cli-version snapshot`` shortcut to mark version with current datetime as meta tag.

Publication
~~~~~~~~~~~

1. Just make sure the canonical file lists the proper version/tags.
   And the versioned-file lists must list all paths explicitly, no globs
   (yet..).

2. ``cli-version check`` verify source before commit, or push. But depends on external
   file. May want some better extensible but still performant setup for different formats.

   Also, packaging may not only concern tagging and deployment (environment), but
   maybe updating license/copyright lines as well from date, license and author (owner).


Short description
~~~~~~~~~~~~~~~~~~
The `update` runs over all files in ``.versioned-files.list``--
including the main file, and runs replaces for various forms of embedded metadata
based on its filename/subpath.

Some commands are to update the version and tags programatically from the command-line.

After adding a document to the list, the location of the sentinel or source-id
line should be given. git-versioning does not insert lines, and is futher
limited by sed-based (iow. line-based regex) find/replace.

Example lines from var. formats, these::

  :Version:
  .. Id: my-app
  # Id: my-app
  VERSION=; # my-app
  var version = null; # my-app

should correctly initialize as is.

The first line only works like that in a main rSt file.
Maybe should fix that, but would go along with making file-formats/templates more pluggable.

| TODO: use complete semver and variations for testing.
| TODO: some integration with GIT frontend? Some ideas:

- maybe ``git ci -m " vpat++ "``. Was nice to have. Expand tag to version?
- something like ``git ci -m " v:testing "``

- Any (semi-)automated committer/tagger needs to reset tags for env after each
  increment. And commit the source in that state to start a new release (branch
  perhaps).

- Maybe choose weither to use env-name as either build-meta or release tag
  (by default) using options.

- XXX: Tags using project name (``app-name/0.0.1``) are nice when dealing with
  seed projects perhaps. But some services may fail to see the tag as (software)
  version.


Working examples:

- ``./bin/cli-version.sh pre-release dev``
- see cli-version. Everything mentioned should be working too.

- ``make tag`` assumes clean project. Marks current GIT HEAD with two tags,
  a simple version and an application-Id with name+version.
  For example ``0.0.0`` and ``app-name/0.0.0```.

  This so if the tags leak to another project repo, it is clear where the tag is from.
  And also since some software may expect a simple '0.0.0' tree-ish to exist to
  install a certain version.

  But I still like the old era ``<NAME>/<MAJOR>.<MINOR>`` program ID convention too
  and with GIT seed/mixin repos one need to be carefull with tags that get into
  projects marking the seed commits, but not versions of the actual software..


----

.. [#] `Semantic Versioning 2.0.0`__
.. [#] A successful Git branching model
  http://nvie.com/posts/a-successful-git-branching-model/

.. __: semver2_

.. _semver2: http://semver.org/spec/v2.0.0.html
.. _semver: http://semver.org/

.. Id: git-versioning/0.0.31-dev+20160321-0713
