.. include:: ../.default.rst

Development Documentation
-------------------------
Should research some of the issues below before continueing dev.

`Project flows <project-flows.rst>`_


Issues
------
GITVER-1 New Feature: SCM-change detection
  Currently Id-comments are always expanded, even if the file has not changed
  for that version. It is also a bit silly to update (and commit) all files
  with a new comment just about updating the versions.

  Introduce a mode where they are only expanded if they actually changed for
  that version.

  Iow. a mode that modifies the current check to checks for the version strings,
  but only before committing them.

  This splits up embedded versions into two categories: Id's, those that
  identifies the source-code version, and would in this mode not change per
  increment. And variables and metadata declarations, those that should
  represent the current project version by using something like a semver or
  GIT commitish.

  Such improvement may also work towards helping with changelog keeping,
  creating a list of changes from commit messages, and listing them per
  file.

GITVER-2 BUG: git-versioning check
  ``git-versioning check`` is incomplete. It gives success on a single match.
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

TODO: maybe rename git-version{ing,}.. to something else.

TODO: kw expansion with git attributes
  was not aware of GIT keyword expansion at time of writing git-versioning.
  https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes#Keyword-Expansion
  This may make things more easy. It does not ever store the Id's, but
  updates on checkout and cleans before staging.

..

  TODO: think about some manner of placeholders and match/substitute modes. Ideas::

    # Id: git-versioning/!git-versioning version
    <!-- Id: git-versioning/${git-versioning.version} doc/manual.rst -->
    .. Id: git-versioning/{version} doc/manual.rst

    .. {ver-marker}: {app-id}/{version} {path} {date}

    var version = "{version}"; # {app-id} {date}
    var lib_version = "{lib.version}"; # {app-id.lib}

    {app-id}.version={version}

..

  TODO: see about ChangeLog type checks, to use before release

..

  TODO: basherpm/basher seems like a nice easy way to install. Resolve some path
  issue though.

..

Other version format?
  ..

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

