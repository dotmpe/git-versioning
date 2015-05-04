GIT Versioning Hooks
====================
.. Id: git-versioning/0.0.16-dev-master+20150504-0239 ReadMe.rst

:Created: 2015-04-19
:Version: 0.0.16-dev-master+20150504-0239
:Status: Dev
:project:

  .. image:: https://secure.travis-ci.org/dotmpe/git-versioning.png
    :target: https://travis-ci.org/dotmpe/git-versioning
    :alt: Build

:repository:

  .. image:: https://badge.fury.io/gh/dotmpe%2Fgit-versioning.png
    :target: http://badge.fury.io/gh/dotmpe%2Fgit-versioning
    :alt: GIT


.. admonition:: Features

   - Use a single script to increment semver version numbers using
     one leading document as the canonical edition; incrementing and updating 
     all versioned files from this number and pre-release and/or build meta tag(s).

   - Among others supports updating source files with hash-comments and global
     variable declarations such as::

         # Id: application-name/1.0.0-alpha+exp.sha.5114f85 path/to/source.ext

         version="1.0.0-alpha+exp.sha.5114f85"; # application-name


Looking around for a GIT versioning hook it seemed mildy simple at first, but
then some different scenarios and issues emerged.
What to commit, and when is not that predictable outside any CI environment.
Taken a step back, more important points are raised by semver2_. [#]_

Semver makes a big deal of stable, well-defined states of software that at
any point have a sensible patch- or upgrade-path. Stable in the sense of
version, not of application stability.

With the inevitable misbehaviour and incompleteness of software, 
stable versions allow to navigate the patches and releases to
fixed versions and new or updated features.

Stable also implies its state is well-defined: something documented maybe 
by use cases, requirements, test scenarios or implicit in automatic tests
scripts, deployment environments etc.

Some exploration in getting metadata out and into different file formats still
lies ahead. (Because although this is meant as a seed project, it would be nice
to offer a certain ease of GIT seeding/mixing: painless fast-forwards are not 
possible if scripts here are refactored but changed upstream in real projects.)

Ideas for actual GIT hooks are emerging, but the only GIT hook here has a FIXME
tag :)
Maybe, before the 1.0 mark this should be a standalone installable too--if ever.



Semver summary
--------------
This use case builds on a `semver` ``MAJOR.MINOR.PATCH`` version specification.
Here is my breve extract of `Semantic Versioning 2.0.0`__.

.. __: semver2_

1. 0.x.y being development versions with unstable API
2. 1.0.0 being the first public API version
3. public API versions never have code changes
4. minor versions increase with backward compatible API changes
5. major versions increase with backward incompatible API changes [*]_.
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


.. [*] Though I think either management or sales may disagree. And also what's 
  compatible or not, that might be determined by what support can fix anyway.


Work flow
---------
Before and during development:

1. Prep GIT project and ``.versioned-files.list``.
2. Write main doc (e.g. ``ReadMe.rst``) to contain start version and tags.
3. ``cli-version update`` update embedded metadata.
4. Commit changes under pre-release tagged versions until final package commit,
   see the next flow.

Packaging (manual or CI-automated):

* ``cli-version increment [vmin [vmaj]]`` increment to new version (and discard tags).
* ``cli-version build|pre-release tags[..]`` mark version with given release or build tag(s) respectively. Or use:
* ``cli-version dev|testing|unstable [tags..]`` shortcut to mark pre-release with tag 'dev', 'alpha' or 'beta' resp.
* ``cli-version snapshot`` shortcut to mark version with current datetime as meta tag.

Publication:

1. Just make sure the canonical file lists the proper version/tags. 
   And the versioned-file lists must list all paths explicitly, no globs
   (yet..).

2. ``cli-version check`` verify source before commit. But depends on external
   file. May want some better extensible but still performant setup for different formats. Also, packaging may not only concern tagging and deployment (environment), but 
   maybe updating license/copyright lines as well from date, license and author (owner).

No automated GIT commits/tags are done really. 
Some concrete scenario for OSS deployment may emerge.


Short description
~~~~~~~~~~~~~~~~~~
The `update` runs over all files in ``.versioned-files.list``--
including the main file, and runs replaces for various forms of embedded metadata
in various file formats. The version itself is taken from the canonical document 
(the main file is the first of the list).

Some commands are to update the version and tags from the command-line,
the underlying functions are all in ``lib/git-versioning.sh``. 

After adding a document to the list, the location of the sentinel or source-id 
line should be given. git-version does not insert lines.

Example::

  :Version: 
  .. Id: my-app
  # Id: my-app
  VERSION=; # my-app
  var version = null; # my-app

should correctly initialize. 
The first line only works like that in a main rSt file.
Maybe should fix that, but would go along with making file-formats/templates more pluggable.

| TODO: test all this.
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


Syntax
~~~~~~
Embedded metadata follows some basic rules.
For clike or hash-comment languages::

  # Id: app-id/0.0.0
  # version: 0.0.0 app-id

And while the exact format differs each follows the following pattern::

  version = 0.0.0 # app-id

For some files exceptions are made.
For one, the main file is always assumed to be an rSt file.
Its version line has no app-id qualifier.
Also the package.json has no app-id qualifier at the version line.
Both belong to a single project only.

Supported 'version' variable assignments in Javascript, Coffee, Shell, Makefile.
Each variable starts after a newline and ends with a comment containing the app-id.

For JSON and YAML there can be an indendation before the 'version' tag.

.. rSt example:
.. Id: git-versioning/0.0.16-dev-master+20150504-0239 ReadMe.rst


Deployment
----------
Working with a project requires some additional constraints.

One is the environment, NodeJS and Bower distinguish between 
'development', which has additional tools installed, and other.
Other might be anoter staging area or '' for production.

Test results of deployments indicate the stability of the project.
It is influenced by the state of the testing or acceptation environment(s).
In particular on the stability of explicit known dependencies but indirectly by
the functions offered on the environment host system and its installs and
configs et al.

Further integration of this into a `git-versioning` workflow is for another time
perhaps.

A dev setup with multiple users can have unique pre-release tags
based on username for example, or the GIT branch name.
To keep the version specifier valid for a software product during its
development cycle, it should probably always have a pre-release tag.

Or else you have to increment each commit you change functional code or
configuration, setup, anything really! Its not a matter of what works,
but a matter if wether a checksum of your finished package will always match 
its accorded version!

To describe any further scenarios would need a plan containing the branch and
reposisitory topology and CI systems.
Some starting points are given in the `Short description`_ section.

Generally, a **master**, **dev**\ (elop(ment)) branch layout is the defacto GIT
standard. Simply because Git always starts at master after the root commit.

Other flows could be to name branches after releases (r0.1) and tag the specific 
release versions (v0.1). Creating new branches each version.

But it seems a topic based layout is preferrable, using branches as contineous 
code-related lanes [#]_ but with accordingly different purpose/environments.
And to use GIT tagging then as the natural way to mark the specific release
commits.


GIT hook setup
--------------
A bit hypothetical. Looking at examples of using GIT hooks to automate
versioning work flow.

- A `pre-commit` hook may add new files, but it has no way to get at GIT
  arguments or the commit message. 

  So it could be made to auto-increment or add tags, but not in response 
  to direct user input. Unless user input is setting a env or putting a file
  somewhere..

- The `prepare-commit-msg` could update the message by embedding the
  version, possibly by replacing some placeholder. The placeholder
  might also be a command to increment path/min/maj or to add a tag.
  
  This script cannot update/add any files of the commit.

- A `post-commit` hook could do the same commit message scan,
  and if a trigger is found run some other GIT merge/tag script.

  Conceivably some CI system would start to run before the new particular version
  would be approved and published to the official branch or repository.

  But this might as well happen `pre-commit`, ie. forcing some state before code can
  enter onto a certain branch perhaps.

- A `post-merge` hook could force some increment and a push to a main repo
  to sync versions directly? Or perhaps not increment but then some timestamp
  build meta (snapshot).

In general, if the version is not incremented each commit, or a release-tag
is present in de code during development commits, then the
requirements of semver are *only* applicable to certain snapshots
of a repository. 
This would mean that looking at any GIT version of the project,
for example the latest master could not give honest version data!


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

bin/
  cli-version.sh
    - Command-line facade for lib/git-versioning functions.

tools/
  pre-commit.sh
    - GIT pre-commit hook  Shell script.
    - Scans main-doc Status field for behaviour. Nothing fancy based on branch
      name or deployment env yet.

  post-commit-old.sh
    - Started out with example, tried to make it into pre-commit hook.

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
.. [#] A successful Git branching model
  http://nvie.com/posts/a-successful-git-branching-model/

.. __: semver2_

.. _semver2: http://semver.org/spec/v2.0.0.html
.. _semver: http://semver.org/
.. _sitefile: http://github.com/dotmpe/node-sitefile



