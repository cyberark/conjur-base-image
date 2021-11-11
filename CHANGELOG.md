# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- Bump nginx from 1.14 to 1.20 to resolve CVE-2021-23017.
  [cyberark/conjur-base-image#69](https://github.com/cyberark/conjur-base-image/pull/69)

## [1.0.5] - 2021-11-09

### Changed

- Rolled back Postgres client version, in UBI-based image, back to 10.16 to match Conjur 
  [cyberark/conjur-base-image#62](https://github.com/cyberark/conjur-base-image/pull/62)

## [1.0.4] - 2021-07-22

- Upgraded ubi8 base image to resolve [CVE-2021-33910](https://nvd.nist.gov/vuln/detail/CVE-2021-33910)
  (no specific PR, as the build automatically picked up the new ubi8 image from RedHat)
- Rolled Postgres version back to 10.16 to match Conjur 
  cyberark/conjur-base-image#59](https://github.com/cyberark/conjur-base-image/pull/59)

## [1.0.3] - 2021-06-07

- Postgres version is incremented to 10.17 from 10.16.
  [PR cyberark/conjur-base-image#57](https://github.com/cyberark/conjur-base-image/pull/57)

## [1.0.2] - 2021-04-20

### Security
- Bump nettle from 3.4.1-2 to 3.4.1-4 and gnutls from 3.6.14-7 to 3.6.14-8 to resolve CVE-2021-20305.
  [cyberark/conjur-base-image#53](https://github.com/cyberark/conjur-base-image/issues/53)

## [1.0.1] - 2021-03-29

### Changed
- Postgres version is incremented to 10.16 from 10.15.
  [cyberark/conjur-base-image#48](https://github.com/cyberark/conjur-base-image/issues/48)

## [1.0.0] - 2020-12-15

### Added
- UBI-based Nginx image to support Conjur server running on OpenShift.
  [cyberark/conjur-base-image#28](https://github.com/cyberark/conjur-base-image/issues/28)
- UBI-based image to support Conjur server running on OpenShift. Uses a builder image to install Ruby 
  compiled with FIPS-enabled OpenSSL.
  [cyberark/conjur-base-image#35](https://github.com/cyberark/conjur-base-image/issues/35)
- Use a builder image for OpenLDAP compiled with FIPS-enabled OpenSSL. This is
  included in the Phusion Ruby base image for the DAP appliance
  [cyberark/conjur-base-image#10](https://github.com/cyberark/conjur-base-image/pull/10)

### Changed
- Downgraded Postgres client version from 12 to 10 so that the server tools match
  the server version in the DAP appliance. This ensures version-specific CLI
  arguments and flags are available.
  [cyberark/conjur-base-image#23](https://github.com/cyberark/conjur-base-image/issues/23)
- The project now follows a [semantic version](https://semver.org)-based
  tagging strategy, and tags will no longer directly reference the base image
  version.
  [cyberark/conjur-base-image#42](https://github.com/cyberark/conjur-base-image/issues/42)

### Security
- Bumped Ruby version from 2.5.1 to 2.5.8 to address [CVE-2020-10663](https://nvd.nist.gov/vuln/detail/CVE-2020-10663).

[Unreleased]: https://github.com/cyberark/conjur-base-image/compare/v1.0.5...HEAD
[1.0.5]: https://github.com/cyberark/conjur-base-image/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/cyberark/conjur-base-image/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/cyberark/conjur-base-image/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/cyberark/conjur-base-image/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/cyberark/conjur-base-image/compare/v1.0.0...v1.0.1
