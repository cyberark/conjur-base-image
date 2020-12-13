# Conjur Base Image Build Note for ARM64

## To build & push arm64 & amd64 images

### conjur-base-image
1. openssl-builder
```
cd openssl-builder
./buildx <your docker username>
```

2. ubuntu-ruby-builder
```
cd ubuntu-ruby-builder
./buildx <your docker username>
```

3. postgres-client-builder
```
cd postgres-client-builder
./buildx <your docker username>
```

4. ubuntu-ruby-fips
```
cd ubuntu-ruby-fips
./buildx <your docker username>
```
