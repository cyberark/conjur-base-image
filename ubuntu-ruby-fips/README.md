# Ubuntu container image
This container image includes Ubuntu version `22.04` which contains the following packages:

* OpenSSL: configured to be FIPS compliant.
* Ruby: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler.

The exact versions of packages mentioned above can be found in [Description.md](./Description.md).

## Build step

### Important
The builder image **should not** be used as the eventual application image.
It should be solely used to **build** an actual application image.

FIPS module is disabled in `ubuntu-ruby-builder` image to take advantage of
dependency download optimization bundler utilizes.

Bundler uses MD5 Hash Algorithm which is not FIPS compliant, hence no optimization can be applied on images
with FIPS module enabled. This have a negative toll on the dependencies download speed.

#### Assumptions

1. Current directory is the directory where this repository is cloned
2. Docker version is `24` or higher


### Docker images
| Image name                     | Description                          |
|--------------------------------|--------------------------------------|
| ubuntu-ruby-builder            | Ruby image with building tools       |
| ubuntu-ruby-fips               | Final image                          |
| ubuntu-ruby-fips-postgres-fips | Final image with PostgreSQL database |
| ubuntu-ruby-fips-slim          | Lightweight final image              |


### Steps

To build the images execute:

```
./ubuntu-ruby-fips/build.sh
```

### FIPS-enabled Jenkins hosts (AmznDocker)

When building on a FIPS-enabled host (AmznDocker), Noble containers inherit host FIPS and
can hit [Ubuntu LP #2066990](https://bugs.launchpad.net/bugs/2066990) during `apt-get`, and
`openssl fipsinstall` in `fips_init` can fail HMAC self-tests before config exists.
The Dockerfile prefixes those `RUN`s with `OPENSSL_FORCE_FIPS_MODE=0` (not a durable image
`ENV` — `main` builds on non-FIPS agents and never ships that ENV). Product FIPS via
`fips_init` / openssl.cnf is unchanged. `ubuntu-ruby-builder` still runs with FIPS off for Bundler (MD5).

See [docs/building-on-fips-enabled-hosts.md](../docs/building-on-fips-enabled-hosts.md).
