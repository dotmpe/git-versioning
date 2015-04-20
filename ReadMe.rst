GIT Versioning Hooks
====================
:Created: 2015-04-19
:Version: 0.0.6
:project:

  .. image:: https://secure.travis-ci.org/dotmpe/git-versioning.png
    :target: https://travis-ci.org/dotmpe/git-versioning
    :alt: Build

:repository:

  .. image:: https://badge.fury.io/gh/dotmpe%2Fgit-versioning.png
    :target: http://badge.fury.io/gh/dotmpe%2Fgit-versioning
    :alt: GIT



Looking around for a GIT versioning hook it seemed really simple at first,
but then some different scenarios and issues emerged.

Taken a step back, more important points are raised by semver2_.

Semver makes a big deal of stable, well-defined states of software
that at any point have a sensible patch- or upgrade-path. In case of 
bugs--or simply because of updated/additional features.

This implies this state is well-defined: documented by
use cases, requirements, test scenarios etc.


Semver summary
--------------
This use case builds on a `semver` ``MAJOR.MINOR.PATCH`` version specification.

1. 0.x.y being development versions with unstable API
2. 1.0.0 being the first public API version
3. public API versions never have code changes
4. minor versions increase with backward compatible API changes
5. major versions increase with backward incompatible API changes
6. the version spec may be amended by pre-release-version tags: ``-[0-9A-Za-z-]\.``
7. the spec may be amended by build metadata tags: ``+[0-9A-Za-z-]\.``

E.g.::

    1.0.0-alpha+exp.sha.5114f85

The nice thing about semver is it has a clear concept of publicity
and stability. 
For one thing, there is no need to commit to a public version, giving a 
clear indication a project may not be there yet--or maybe not intendend as such at all,
marking for sandboxed, experimental use only.

Also, from this follows that any project metadata must hold some pre-release 
version during development. This should uniquely identify the state wether in 0.x.y 
or in post-1.0.0 range.

This way tags, commits, metadata, docs etc. always contain the appropiate version,
and there are no ambigious source states.


Work flow
---------
Before and during development:

1. Prep GIT project and ``.versioned-files.list``
2. Write main doc (``ReadMe.rst``) to contain start version and tags
3. ``cli-version update`` update embedded metadata

Packaging (manually or CI-automated):

* ``cli-version increment [vmin [vmaj]]`` increment main
* ``cli-version testing [tags..]`` pre-release with 'alpha' default tag
* ``cli-version unstable [tags..]`` pre-release with 'beta' default tag
* ``cli-version pre-release tags[..]`` mark version with tags

* ``cli-version snapshot`` add timestamp meta mark
* ``cli-version build meta[..]`` mark version with meta

Publication:

1. ``cli-version check`` verify source before commit
2. ``cli-integrate`` demonstration of example GIT commit, tag, branch and push flow

Short description
~~~~~~~~~~~~~~~~~~
The `update` command allows to set versions and release/build-tags
and populate the other files listing in ``.versioned-files.list``.
Other commands are to update the version from the command-line,
the underlying functions are all in ``lib/git-versioning.sh``

TODO: some integration with GIT frontend

- maybe ``git ci -m " vpat++ "``
- or something like ``git ci -m " v:testing "``
- Need to reset tags for env each increment.

Working examples:

- ``./tools/cli-version.sh pre-release dev``
- ``make patch m="Commit msg"``

Deployment
----------
Working with a project requires some additional constraints.

One is the environment, NodeJS and Bower distinguish between 
'development', which has additional tools installed, and other.
Other might be anoter staging area or '' for production.

Wether the project checks out/builds/installs on a environment
would say something about the projects stability.

Further integration of this into a git-versioning workflow is for another time
perhaps.

A dev setup with multiple users can have unique pre-release tags
based on username for example, or even based on (abbreviated) GIT sha1sums.


GIT hook setup
--------------
A bit hypothetical. Looking at examples of using GIT hooks to automate
versioning work flow.

- A `pre-commit` hook may add new files, but it has no way to get at GIT
  arguments or the commit message. 

  So it could be made to auto-increment or add tags, but not in response 
  to direct user input.

- The `prepare-commit-msg` could update the message by embedding the
  version, possibly by replacing some placeholder. The placeholder
  might also be a command to increment path/min/maj or to add a tag.
  
  This script cannot update/add any files of the commit.

- A `post-commit` hook can do the same commit message scan,
  and if a trigger is found run some other GIT merge/tag script.

  Conceivably some CI system would start to run before the new particular version
  would be approved and published to the official branch or repository.

- A `post-merge` hook could force some increment and a push to a main repo
  to sync versions directly.

In general, if the version is not increment each commit, then the
requirements of semver are only applicable to certain snapshots
of a repository.


GIT config
----------
Use GIT as frontend for make recipes. Commit new patch::

  [alias]
    patch = !make patch m="$1"


Package contents
----------------

.versioned-files.list
  - A plain text list of paths that have version tags embedded.
  - The first path contains the canonical tags.

lib/git-versioning.sh
  - Shell script functions library.

tools/
  pre-commit.sh
    - GIT pre-commit hook Shell script.
    - Updates embedded metadata and add modified files to GIT staging area.
      FIXME: if triggered, need a trigger

  cli-version.sh
    - Command-line facade for lib/git-versioning functions.

  version-check.sh
    - Default check greps all metadata files to verify versions all match.

package
  .json
    - NPM standard project metadata file.
  .yaml
    - Another currently meaningless project metadata file.

Sitefile.yaml
  - Metadata for documentation browser sitefile_

reader.rst
  - For use with sitefile_

Makefile
  - Nothing much.


----

.. [#] `Semantic Versioning 2.0.0`__
.. __: semver2_

.. _semver2: http://semver.org/spec/v2.0.0.html
.. _semver: http://semver.org/
.. _sitefile: http://github.com/dotmpe/node-sitefile

