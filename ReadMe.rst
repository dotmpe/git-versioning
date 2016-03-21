GIT Versioning Hooks
====================
:Created: 2015-04-19
:Version: 0.0.30
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


.. contents::


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

* ``cli-version increment [vmin [vmaj]]`` increment to new version (and discard tags) when needed.
* ``cli-version build|pre-release tags[..]`` mark version with given release or build tag(s) respectively, or rather to reset them for a proper release.

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


Syntax
~~~~~~
For clike or hash-comment languages::

  # Id: app-id/0.0.0 path/filename.ext
  # version: 0.0.0 app-id path/filename.ext

And while the exact format differs they mostly follow the pattern::

  version = 0.0.0 # app-id

For some files exceptions are made. Refer to test/example files for syntax
per format.

The app-id is mostly included to avoid and ambiguity.
Exact specs of variable rewrites may differ per format since its not always
possible to include a comment on the line (ie. JSON).


.. rSt example:
.. Id: git-versioning/0.0.30 ReadMe.rst



Dev
---

Other version format?
  XXX: not directly a semver, but git describe also offers a version tag for the current commit (last tag, number of commits since, abbrev commit sha and dirty flag)::

    $ git describe --long --tags --dirty --always
    0.0.26-60-g265df19-dirty

  https://blog.mozilla.org/warner/2012/01/31/version-string-management-in-python-introducing-python-versioneer/
  XXX: article on issues with embedded versions introduces python setup tool 'Versioneer'; this uses the git describe version, and placeholder expansion in _version.py upon moving code to dist (git archive). This git describe version thing is not really suited for embedded versions since its always about the last commit.
  But maybe interesting in other formats.

  Also, version comparisons supported by various packagers may be worth to look
  at [ie. Py PEP440 etc].

Project flows
  TODO: development, stabilization, release. Can some scripts help? Looking at the tools and issues.

  GIT hooks analysis
    - A `pre-commit` hook may add new files, but it has no way to get at GIT
      arguments or the commit message?

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

  This would mean that looking at any GIT reversion of the project,
  for example the latest commit would not give honest version data! I prefer to
  try to keep the code unambigious at the source. Semver allows release and
  build tags (release tags are included in comparisons, build tags ignored).
  Semver also says these may be incompatible or unstable w.r.t the numeric release.
  The build tag in this case is associates with a development series, releasing
  or tagging more often may help shipped code to be more easily identified, but
  is not a requirement.


  XXX: current Status field behaviour is undocumented, see pre-commit. there's release,
  dev\* and mixin status. Status is the first word in the docfield field:

  - Release removes all tags, then checks the files and stages them. Ie. that
    commit would contain the version without any tags, and must then be the
    commit to tag with that release version.

  - Dev\* sets the dev-<branch>+<timestamp> version, and checks+stages files.
    To keep development branches somewhat informative, but see issues described
    further on.

  - Mixin sets release tag to mixin. Unused, but may want to look at use-case of
    seed projects or boilerplates further.


  Current Development flow
    The current pre-commit is not used since it always updates the embedded version,
    which is a pain during development. Moving code across a version requires a
    lot of merging.

    XXX: After each version update, any downstream branch that has its own version (tags)
    will give a conflict on every version line on the next upstream merge.

    This has to be dealt with manually: if the version commits upstream are clean otherwise,
    it is a simple git merge -s ours on that commit, then a version update on the local branch to
    reflect the proper version after merge, and finally a normal merge with the rest from the
    upstream branch.

    XXX: It should pay therefore to have tags pointing to these version-update commits.
    However keeping all pre-release (development, features, testing and other derived) versions as tags in the repository will obviously not do.
    A little housekeeping is needed, because once a proper release is made, all these branch version tags should be cleaned--after they are merged with the
    release commit. This way certain branches like feature development or test or
    demo branches are sure to be up-to-date, and each have a version with
    [pre-]release tag to warn it is not a well-defined, but in-between or derived version.

    But this requires not only a fancier make tag setup, but also a build system that performs the merges automatically.

    This way using GIT tags and embedded versions, all project flow stays in the repository.



GIT config
----------
Use GIT as frontend for make recipes. Commit new patch::

  [alias]
    patch = !make patch m="$1"


Package contents
----------------

.versioned-files.list
  - A plain text list of paths that have version tags embedded.
  - The first path is the main file, that contains the canonical tags
    used for ``git-versioning update``.

bin/
  cli-version.sh
    - Command-line facade for lib/git-versioning functions.
      Symlinked to ``git-versioning`` in ``$PREFIX/bin/``.

lib/
  formats.sh
    The place for sed-based file rewrite functions.
  git-versioning.sh
    Shell script functions library.
  util.sh
    ..

tools/
  git-hooks/
    pre-commit.sh
      - GIT pre-commit hook  Shell script.
      - Scans main-doc Status field for behaviour. Nothing fancy based on branch
        name or deployment env yet.

    post-commit-old.sh
      - Started out with example, tried to make it into pre-commit hook.

  cmd/
    prep-version.sh
      - Add current GIT branch name as version pre-release tag.
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
  - Some development targets.
    See also configure script and .travis.yml config.



----

.. [#] `Semantic Versioning 2.0.0`__
.. [#] A successful Git branching model
  http://nvie.com/posts/a-successful-git-branching-model/

.. __: semver2_

.. _semver2: http://semver.org/spec/v2.0.0.html
.. _semver: http://semver.org/
.. _sitefile: http://github.com/dotmpe/node-sitefile

.. Id: git-versioning/0.0.30 ReadMe.rst
