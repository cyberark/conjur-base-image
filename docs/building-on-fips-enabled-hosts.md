# Building on FIPS-enabled hosts (CNJR-13114)

How `ubuntu-ruby-fips` builds on **FIPS-enabled** Jenkins hosts (`conjur-enterprise-AmznDocker`),
and how that differs from product FIPS in the shipped images.

---

## FAQ

### Why is `OPENSSL_FORCE_FIPS_MODE=0` set?

**Only during `apt-get` / package-install `RUN` steps in**
[ubuntu-ruby-fips/Dockerfile](../ubuntu-ruby-fips/Dockerfile) — never as a durable image `ENV`.

| Fact | Detail |
|------|--------|
| Why needed | AmznDocker enables **host** kernel FIPS. Noble containers inherit `/proc/sys/crypto/fips_enabled=1`. Stock Noble OpenSSL then fails during `update-ca-certificates` ([Ubuntu LP #2066990](https://bugs.launchpad.net/bugs/2066990); often logged as "out of memory"). |
| Why not on `main` | Default-branch CI uses `conjur-enterprise-common-agent` + InfraPool **ExecutorV2** (host FIPS **off**). That pipeline never needed the override. |
| Why not `ENV` | Baking `OPENSSL_FORCE_FIPS_MODE=0` into `Config.Env` diverges shipped images from `main` and can override kernel FIPS inheritance for consumers. Prefix apt/`RUN`s only. |
| Not a product FIPS change | Host FIPS ≠ image FIPS. Product FIPS for `ubuntu-ruby-fips` remains **`fips_init`** / openssl.cnf (`default_properties = fips=yes`). |

**Host FIPS stays enabled** on AmznDocker. The override is a build-time accommodation so Noble apt works on that host.

### Was the build failure a real memory (OOM) issue?

**No.** Logs showed "out of memory" during `apt-get install ca-certificates`, but the root cause is LP #2066990 on FIPS-enabled hosts — not host RAM exhaustion.

### Do `*-fips` images require a FIPS CI host?

**No.** Product FIPS is configured **inside** the image via `fips_init`. `main` builds these images on non-FIPS agents. AmznDocker host FIPS only affects the **build** path (apt workaround above).

| Image | Default runtime FIPS | Notes |
|-------|---------------------|-------|
| `ubuntu-ruby-fips` | ON | via `fips_init` / default `openssl.cnf` |
| `ubuntu-ruby-builder` | OFF | Bundler uses MD5 (`OPENSSL_CONF=openssl_non_fips.cnf`) |
| `ubi-ruby-fips` | OFF | toggle via `OPENSSL_CONF=openssl_fips.cnf` |
| `ubi-ruby-builder` | OFF | same Bundler reason |

### Why did `fips_mode` change?

`fips_mode` used to grep `openssl list -providers` for `fips`, which can report "enabled" on FIPS **hosts** even when the image config has FIPS off (ubi). It now checks `default_properties = fips=yes` in the active openssl config file (image-configured state).

### FIPS layers (summary)

| Layer | FIPS state | Notes |
|-------|------------|-------|
| AmznDocker host | ON | `fips-mode-setup --enable` in AmznDocker userdata |
| ExecutorV2 / common-agent host (`main`) | OFF | No apt workaround needed |
| Noble build `apt-get` on AmznDocker | `OPENSSL_FORCE_FIPS_MODE=0` on that `RUN` only | LP #2066990 |
| Shipped `ubuntu-ruby-fips` | ON via `fips_init`; **no** `OPENSSL_FORCE_FIPS_MODE=0` in ENV | Matches `main` Config.Env |
| `ubi-ruby-fips` runtime | OFF (default) | product config |

---

## CI migration: common-agent + ExecutorV2 → AmznDocker

| Role | `main` (default branch) | AmznDocker (CNJR-13114) |
|------|-------------------------|-------------------------|
| Pipeline orchestrator | `conjur-enterprise-common-agent` | `conjur-enterprise-AmznDocker` |
| amd64 build worker | 1× InfraPool **ExecutorV2** | 1× **AmznDocker** |
| arm64 build worker | InfraPool **ExecutorV2ARM** | InfraPool **ExecutorV2ARM** |

**Total AmznDocker EC2 per build: 2** (orchestrator + amd64 worker).

```
Build and Test (parallel):
  ├── ubuntu-ruby-fips arm64  → ExecutorV2ARM (agentSh)
  ├── ubi-ruby-fips arm64     → ExecutorV2ARM
  ├── ubi-nginx arm64         → ExecutorV2ARM
  └── amd64 images            → 1× AmznDocker node, inner parallel:
                                  ├── ubuntu-ruby-fips amd64
                                  ├── ubi-ruby-fips amd64
                                  └── ubi-nginx amd64
```

### Related Dockerfile / test changes

1. `OPENSSL_FORCE_FIPS_MODE=0` prefixed on Noble apt/`RUN`s (not durable `ENV`).
2. `fips_mode` — config-based detection ([ubuntu-ruby-fips/fips_mode](../ubuntu-ruby-fips/fips_mode), [ubi-ruby-fips/fips_mode](../ubi-ruby-fips/fips_mode)).
3. Structure tests assert `OPENSSL_FORCE_FIPS_MODE` is not baked as `0`; apt in test setup uses the same RUN-scoped override when needed.

---

## References

- [Ubuntu LP #2066990](https://bugs.launchpad.net/bugs/2066990)
- [ubuntu-ruby-fips/Dockerfile](../ubuntu-ruby-fips/Dockerfile) (comment block at top)
- AmznDocker host FIPS: `conjur-enterprise-AmznDocker` userdata (`fips-mode-setup --enable`)
