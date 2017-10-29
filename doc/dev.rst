Development Documentation
=========================
.. include:: ../.default.rst


r0.3 golang fork. Look at doing some gitflow-ish checks too.

And use GIT smudge filters::

  git config --global filter.gitver.clean $(pwd)'/git-versioning filter clean'
  git config --global filter.gitver.smudge $(pwd)'/git-versioning filter smudge'

Status:
  no filters yet.
  .gitattributes allows to apply selectively, preventing issues where expansion
  is unwanted. But also takes away filename from filter, so no per-format
  considerations.

  Should make things more simpler. Considering this for new config syntax::

    [[filter]]
    match = ... # replace pattern
    smudge = ... # replace subtitution
    clean = ... # cleanup pattern, to revert replacement

    # Emulating svn/vcs/rcs

    [[filter]]
    match = "$Id$"
    smudge = "$Id: {commit} $"
    clean = "$Id[^$]*$"

    [[filter]]
    match = "$Date$"
    smudge = "$Date: {date} $"
    clean = "$Date[^$]*$"


    # My own fav.

    [[filter]]
    match = "Id: {app-id}"
    smudge = "Id: {app-id}/{version} {file}"
    clean = "Id: {app-id}.*"


    # Something new maybe, would replace all occurences of application name ID

    [[filter]]
    match = "$App-Id$"
    smudge = "{app-id}"
    clean = "{app-id}"


Other documents
---------------
- `GIT hooks <git-hooks.rst>`_
- `Initial analysis (ReadMe) <doc/initial-analysis.rst>`_
- `Change Log <ChangeLog.rst>`_
- `Branche and Directory Docs <doc/package.rst>`_


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

GITVER-7 New Feature: provide GIT smudge/clean filters, maybe help with setup
  was not aware of GIT keyword expansion at time of writing git-versioning.
  https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes#Keyword-Expansion

  Note the manual acknowledges that SCN/CSV-style keyword expansion is not that
  useful since it expans into the Blob SHA-1, not the final commit SHA1.
  The placeholder format used is e.g. ``$Id$``. Or ``$Date$``.

  GIT filters are simply stream editors, and put in global config (ie.
  distribute seperately from repo)::

    git config --global filter.indent.clean indent
    git config --global filter.indent.smudge cat

  And used per project in ``.gitattributes``::

    *.c filter=indent

TODO: maybe rename git-version{ing,}

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
