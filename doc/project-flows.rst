TODO: development, stabilization, release. Can some scripts help? Looking at the tools and issues.

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
