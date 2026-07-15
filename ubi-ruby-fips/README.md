# UBI container image
This container image includes UBI version `9` which contains the following packages:

* OpenSSL: with FIPS 140-2 compliant OpenSSL module from RedHat UBI 9.
  Please note for this image FIPS module is disabled by default.
  On how to toggle on/off, please refer to [Toggle FIPS mode on/off](#toggle-fips-mode-onoff). 
* Ruby: compiled against the FIPS 140-2 compliant OpenSSL module.
* Postgres client: linked against the FIPS 140-2 compliant OpenSSL module.
* Bundler.

The exact versions of packages mentioned above can be found in [Description.md](./Description.md).

## Build step

### Important

The builder image **should not** be used as the eventual application image.
It should be solely used to **build** an actual application image.

FIPS module is disabled in `ubi-ruby-builder` image to take advantage of
dependency download optimization bundler utilizes.

Bundler uses MD5 Hash Algorithm which is not FIPS compliant, hence no optimization can be applied on images
with FIPS module enabled. This have a negative toll on the dependencies download speed.

#### Assumptions

1. Current directory is the directory where this repository is cloned
2. Docker version is `24` or higher


### Docker images
| Image name         | Description                    |
|--------------------|--------------------------------|
| ubi-ruby-builder   | Ruby image with building tools |
| ubi-ruby-fips      | Final image                    |
| ubi-ruby-fips-slim | Lightweight final image        |


### Steps

To build the images execute:

```
./ubi-ruby-fips/build.sh
```

### Toggle FIPS mode on/off

Due to the fact `fipsinstall` command is disabled on the container level in UBI9 image
(through patched OpenSSL source), it is not possible to control the FIPS mode through
`openssl fipsinstall` command.

This posed a failures on OpenShift [tests](./test.sh).

In order to allow the tests to pass, a fips mode configuration file was introduced,
which then is read in [fips_init@14](./fips_init) during initialization of the container.

The parameter `OPENSSL_CONF=/etc/pki/tls/openssl_fips.cnf` controls the toggling of the
FIPS mode.

For additional information, please refer to 
[official OpenSSL documentation](https://github.com/openssl/openssl/blob/master/README-FIPS.md#installing-the-fips-provider).

### Testing on FIPS-enabled hosts

When container-structure-test runs on a FIPS-enabled Jenkins host (AmznDocker), the kernel
FIPS flag can make `openssl list -providers` show the FIPS provider even when this image's
default config has FIPS off. The `fips_mode` script requires both
`default_properties = fips=yes` in the active openssl config and a loaded FIPS provider, so
default (FIPS-off) images still report disabled despite host leakage. Algo-denial structure
tests remain the strong check that FIPS is actually enforced when enabled.

See [docs/building-on-fips-enabled-hosts.md](../docs/building-on-fips-enabled-hosts.md).