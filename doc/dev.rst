.. include:: ../.default.rst

Development Documentation
-------------------------
Other tooling may offer other entry points, but for all parts these scripts
are so dependent on GIT that they are named after that. But being shell scripts
other integrations (NPM, Composer) are possible.

Unfortunately GIT does not offer any help in distributing and installing GIT
hooks. There is an assortment of helper in all sorts.

This site on Hooks <https://githooks.com/> is the best starting point.

Project flows
_____________
Since we're on GIT this about summarizes the offer:

- pre-commit: Check the commit message for spelling errors.
- pre-receive (server): Enforce project coding standards.
- post-commit: Email/SMS team members of a new commit.
- post-receive (server): Push the code to production.

Where 'receive' phase scripts are executed post-push on the 'remote' side
hence called server. However for for non-server phase scripting, special
dependencies or significant resources may be required. Ie. static analysis
takes a lot of memory, other tests result in high IO for disk, network and
lots of cache request and rewindowing will happen because of the size of some
regular CI scripting.

Ie. to build the flow, two endpoints at least on two environments: dev and source hosting. Probably a user env, deployment and possibly CI, CD around that.

GIT hooks analysis
 - A `pre-commit` hook may add new files, but it has no way to get at GIT
   arguments or the commit message?

   So it could be made to auto-increment or add tags, but not in response
   to direct user input ie. args. Unless user input is setting a env or
   putting up a file somewhere..

 - The `prepare-commit-msg` could update the message by embedding some value
   possibly version, possibly by replacing some placeholder. The placeholder
   might also be a command to increment path/min/maj or to add a tag.

   This script cannot update/add any files of the commit.

 - A `post-commit` hook could do the same commit message scan,
   and if a trigger is found run some other GIT merge/tag script.

   Conceivably some CI system would start to run before the new particular
   edition would be approved and published as the new/latest version to
   official branch or repository.

   But this might as well happen `pre-commit`, ie. forcing some state before
   code can move onto a certain branch perhaps.

 - A `post-merge` hook could force some increment and a push to a main repo
   to sync versions directly? Or perhaps not increment but then some timestamp
   build meta (snapshot).

GIT discussion
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


Issues
------
GITVER-1 New Feature: SCM-change detection
  Currently Id-comments are always expanded, even if the file has not changed
  for that version. It is also a bit silly to update (and commit) all files
  with a new comment just about updating the versions.

  Introduce a mode where they are only expanded if actually changed in SCM.
  Iow. a mode that checks for the version strings, but also the SCM versions.
  And provide for the git-hooks to update files on the fly.

GITVER-2 BUG: git-versioning check
  ``git-versioning check`` is incomplete. It success on a single match.
  It should check all marked versions.

GITVER-3 Enhancement: Command-Line Options
  Add a few functions to do simple short and long option parsing.

  GITVER-4 Enhancement: Formatting Options
    Selectively apply replaces using options. E.g. process only Id comment lines,
    or only versions literals. Look about customizing format too.

    GITVER-5 New Feature: add formats on the run
      Introduce a mode to expand Id/version regardless of wether format is known.

  GITVER-6 New Feature: git-versioning init [FILE...]
    Intialize files by adding comment lines (if no version match found). Add a new
    mode that appends the Id-comment and initializes the .versioned-files.list


TODO: maybe rename git-version{ing,}

TODO: kw expansion with git attributes
  was not aware of GIT keyword expansion at time of writing git-versioning.
  https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes#Keyword-Expansion
  This may make things more easy. It does not ever store the Id's, but
  updates on checkout and cleans before staging.


TODO: basherpm/basher seems like a nice easy way to install. Resolve some path
issue though.


Other version format?
  XXX: not directly a semver, but git describe also offers a version tag for the current commit (last tag, number of commits since, abbrev commit sha and dirty flag)::

    $ git describe --long --tags --dirty --always
    0.0.26-60-g265df19-dirty

  For a more complete solution see https://github.com/GitTools/GitVersion

  https://blog.mozilla.org/warner/2012/01/31/version-string-management-in-python-introducing-python-versioneer/
  XXX: article on issues with embedded versions introduces python setup tool 'Versioneer'; this uses the git describe version, and placeholder expansion in _version.py upon moving code to dist (git archive). This git describe version thing is not really suited for embedded versions since its always about the last commit.
  But maybe interesting in other formats.

  Also, version comparisons supported by various packagers may be worth to look
  at [ie. Py PEP440 etc].


More in TODO.list


GIT config
----------
Use GIT as frontend for make recipes. Commit new patch::

  [alias]
    patch = !make patch m="$1"

