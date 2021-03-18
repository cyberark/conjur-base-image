# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/cyberark/conjur-base-image/compare/v1.0.0...HEAD
