# postgres
Base PostgreSQL image for digital applications.  includes; postgis, plv8

Checkout branch for version of PostgreSQL you want to use.

- [16](https://github.com/ucd-library/postgres/tree/16)


## Usage

```bash
docker run --name postgres -p 5432:5432 us-west1-docker.pkg.dev/digital-ucdavis-edu/pub/postgres:16
```