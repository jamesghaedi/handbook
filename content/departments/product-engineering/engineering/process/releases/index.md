# Sourcegraph releases

This document describes how we release Sourcegraph.

## Release policies

> As of Feb 3, 2022, the role of Release Captain is now rotation-based within the [Cloud](../../cloud/index.md) org, [learn more](https://sourcegraph.slack.com/archives/C0EPTDE9L/p1643915838386829). If you need assistance with releases, please reach out to [#delivery](https://sourcegraph.slack.com/archives/C02E4HE42BX). The [Delivery] team is more than happy to help you through the process.

### Releases

**Sourcegraph releases are monthly.**
A _release_ refers to a minor version increase of Sourcegraph (e.g. `3.0.0` -> `3.1.0`).
We create releases by 10am US Pacific Time on the 20th day of each month. ([why?](#why-the-20th))

These releases **may** require [manual migration steps](https://docs.sourcegraph.com/admin/updates).

These releases always ship on time, even if they're missing features or bug fixes we hoped to get in ([why?](https://about.gitlab.com/2015/12/07/why-we-shift-objectives-and-not-release-dates-at-gitlab/)).

### When we release

The release branch will be cut on the last working day at 10am PST before the 20th of each month.

If the 20th falls on a non-working day, the release captain will move the release earlier, to the last working day before the 20th, as well as cutting the release branch the day before that. The calendar events will reflect this.

eg. The 20th of a given month falls on a Sunday, therefore the release will be moved earlier to the last working day before the 20th (the 18th) and the branch will cut the day before that (the 17th).

### Patch releases

**Sourcegraph patch releases are created as required.**
A _patch release_ refers to a patch version increase of Sourcegraph (e.g. `3.0.0` -> `3.0.1`).

These releases **never** require any manual migration steps.

> NOTE: Patch releases are not free, and we currently enforce certain requirements before a patch release is conducted.
> To request a patch release, please fill out a [patch release request](https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=team%2Fdistribution%2Cpatch-release-request&template=request_patch_release.md&title=).
> In most cases, waiting until the next [full release](#releases) is the best approach.

### Other

On rare occasions we may decide to increase the major version number (e.g. `2.13.x` -> `3.0.0`).
These releases **may** require [manual migration steps](https://docs.sourcegraph.com/admin/updates).

## Key concepts and components

This section documents the process used to create releases at Sourcegraph.

### Release captain

The release captain is _responsible_ for managing the release process and ensuring that the release happens on time. The release captain may _delegate_ work to other teammates, but such delegation does not absolve the release captain of their responsibility to ensure that delegated work gets done.

The release captain should create a tracking issue using the [release issue template](release_issue_template.md) at the beginning of the release cycle.

Release captain responsibilities are currently owned by the [Release guild](release_guild.md).

#### Release Retrospective

The release captain is responsible to start an async release retrospective for every release. Typically this will be in a google document located in the [Release Guild folder in Google Drive](https://drive.google.com/drive/folders/1KMGL2iS8yuBHU-fJsTqb8lIqyHcO75nB?usp=sharing). We perform these retrospectives so that we can understand and grow. The long term vision is to improve this release process, and to do so we need to gather information about each release.

The retrospective document should be shared in #release-guild.

### Release tooling

The [Sourcegraph release tool] is used to generate releases as associated materials (such as tracking issues).
It leverages the following issue templates, which list all individual steps that needs to be performed, for each type of release:

- [Release issue template](release_issue_template.md)
- [Patch release issue template](patch_release_issue_template.md)
- [Upgrade managed instances issue template](upgrade_managed_issue_template.md)

### Release branches

Each major and minor release of [Sourcegraph](https://github.com/sourcegraph/sourcegraph) has a long lived release branch (e.g. `3.0`, `3.1`).
Individual releases are tagged from these release branches (e.g. `v3.0.0-rc.1`, `v3.0.0`, `v3.0.1-rc.1`, and `v3.0.1` would be tagged from the `3.0` release branch).

To avoid confusion between tags and branches:

- Tags are always the full semantic version with a leading `v` (e.g. `v2.10.0`)
- Branches are always the dot-separated major/minor versions with no leading `v` (e.g. `2.10`).

Development always happens on `main` and changes are cherry-picked onto release branch as necessary **with the approval of the release captain**.

#### Example

Here is an example git commit history:

1. The release captain creates the `3.0` release branch at commit `B`.
1. The release captain tags the release candidate `v3.0.0-rc.1` at commit `B`.
1. A feature is committed to `main` in commit `C`. It will not ship in `3.0`.
1. An issue is found in the release candidate and a fix is committed to `main` in commit `D`.
1. The release captain cherry-picks `D` from `main` into `3.0`.
1. The release captain tags `v3.0.0` on the `3.0` release branch.
1. Development continues on `main` with commits `E`, `F`, `G`, `H`.
1. Commit `F` fixes a critical bug that impacts 3.0, so it is cherry-picked onto the `3.0` release branch and `v3.0.1` is tagged.
1. The release captain (different person) for 3.1 creates the `3.1` release branch at commit `H` and a new release cycle begins.
1. Commit `J` fixes a critical bug that impacts both 3.0 and 3.1, so it is cherry-picked into both `3.0` and `3.1` release branches and new releases are tagged (`v3.0.2`, `v3.1.2`).

```text
A---B---C---D---E---F---G---H---I---J---K---L (main branch)
     \                       \
      \                       `---v3.1.0-rc.1---I'---v3.1.0---J'---v3.1.2 (3.1 release branch)
       \
        `---v3.0.0-rc.1---D'---v3.0.0---F'---v3.0.1---J'---v3.0.2 (3.0 release branch)
```

### Issues

This section documents how do we deal with issues that are found during the release process.

#### Blocking

The release always ships on time, even if it's missing features or bug fixes we hoped to get in ([why?](https://about.gitlab.com/2015/12/07/why-we-shift-objectives-and-not-release-dates-at-gitlab/)).

There are only three kinds of issues that are eligible to block a release:

1. Issues that literally prevent us from tagging a release (i.e. our CI logic to produce builds from git tags is broken).
2. Issues that fundamentally break our product for a _majority_ of our customers and don't have acceptable workarounds.
3. Critical security _regressions_ from the previous release.

Only the release captain can label something as release blocking.

The release captain has unlimited power to make changes to the release branch to resolve release blocking issues. As soon as a release blocking issue is identified, the release captain should decide the least risky way to resolve the issue as soon as possible. A good default action is to identify and revert offending commits from the release branch. In the worst case, this could involve recreating the release branch from an earlier commit on `main`. Project owners can work on `main` to fix the issue, and if the issue is resolved in time, revert the revert and cherry-pick the fix on the release branch.

#### Non-blocking

Most issues are non-blocking. Fixes to non-blocking issues can be fixed in `main` by the code owner who can then `git cherry-pick` those commits into the release branch with the approval of the release captain. Alternatively, broken features can be reverted out of the release branch or disabled via feature flags if they aren't ready or are too buggy.

### CHANGELOG.md

When releasing a new version, the Release Captain may need to manually update the [CHANGELOG.md]. Follow the instruction below:

- [ ] Check past entries in [CHANGELOG.md] to understand the changelog format.
- [ ] Create a new H2 title named `{major}.{minor}.{patch}` (the new version) after the `Unreleased` section if it doesn't already exist.
- [ ] Copy all changelog entries of the commits belong to this patch release into the new H2 title `## {major}.{minor}.{patch}`, grouped into the types they were originally in (e.g. `### Added`, `### Changed`, `### Fixed`, `### Removed`).

## Minor release process

### 1) Start a minor release

Major and minor releases are released on a fixed schedule, see [when we release](#when-we-release).

### 2) Minor release tracking issue

The tracking issue for the current minor release is created as a part of the post-release step from the previous minor release. Learn more from the [release issue template].

The Release Captain should review and follow the instruction in the release tracking release for the next steps. At a high level, it includes the following steps:

- Build a release candidate and verify CI passes
- Publish final images
- Update documentation
- Update references of the image tag to the new version using batch change

### 3) Wrapping up

Follow the instruction from post-release in the release tracking issue to wrap up the release and schedule the next minor release.

## Patch release process

You can reference our [patch release process recording](https://drive.google.com/drive/u/1/folders/1SUp3732AewIKTFcn5cqfvyf5_7d2HyUX) on Google Drive.

### 1) Kickstart a patch release using the [Sourcegraph release tool]

CE or the products team will start requesting a patch release by submitting a [patch release request]. Learn more from the [patch release issue template].

Upon the Delivery team or the Release Captain receives the patch release request and we have decided to roll out a new patch release, the Release Captain should follow the instruction in the [patch release request] issue to kickstart the patch release process. The instruction is located at the bottom of the [patch release request].

### 2) Patch release tracking issue

The [Sourcegraph release tool] creates a patch release tracking issue which contains a list of action items the Release Captain has to perform. Learn more from the [patch release issue template].

The Release Captain should review and follow the instruction in the patch release tracking release for the next steps. At a high level, it includes the following steps:

- Build a release candidate and verify CI passes
- Publish final images
- Update documentation and changelog
- Update references of the image tag to the new version using batch change

### 3) Revisit patch request issue

Now it's a good time to go back to the original [patch release request] and close it.

## FAQ

### Why the 20th?

There is nothing particularly special about using this date for releases, but it does mean we wrap up a release before many teammates go on vacation during the end of December.

### Why aren't releases continuous?

Although [Sourcegraph.com](https://sourcegraph.com) is [continuously deployed](../deployments/instances.md), the version of Sourcegraph that customers use is not continuously released or updated.
This is because:

- We don't think customers would be comfortable with a continuously updated service running on their own infrastructure, for security and stability reasons.
- We haven't built the automated testing and update infrastructure to make continuous customer releases reliable.

In the future, we may introduce continuous releases if these issues become surmountable.

[patch release request]: https://github.com/sourcegraph/sourcegraph/issues/new?assignees=&labels=team%2Fdistribution%2Cpatch-release-request&template=request_patch_release.md&title=
[revert poor onboarding ux change]: https://github.com/sourcegraph/sourcegraph/issues/30197
[release-config.jsonc]: https://sourcegraph.com/github.com/sourcegraph/sourcegraph/-/blob/dev/release/release-config.jsonc
[sourcegraph release tool]: ../../tools/release.md
[sourcegraph/sourcegraph]: https://github.com/sourcegraph/sourcegraph
[sourcegraph/deploy-sourcegraph-docker]: https://github.com/sourcegraph/deploy-sourcegraph-docker
[delivery]: ../../cloud/delivery/index.md
[release issue template]: release_issue_template.md
[patch release issue template]: patch_release_issue_template.md
[upgrade managed instances issue template]: upgrade_managed_issue_template.md
[changelog.md]: https://github.com/sourcegraph/sourcegraph/blob/main/CHANGELOG.md
