![Greenbone Logo](https://www.greenbone.net/wp-content/uploads/gb_new-logo_horizontal_rgb_small.png)

# Greenbone GitHub Actions Workflows <!-- omit in toc -->

Repository that contains a collection of reusable GitHub Actions workflows for
Greenbone projects

- [Workflows](#workflows)
  - [Convention Commits](#convention-commits)
  - [CI Python](#ci-python)
  - [Deploy on PyPI](#deploy-on-pypi)
  - [Codecov Python](#codecov-python)
  - [Release Python](#release-python)
- [Support](#support)
- [Maintainer](#maintainer)
- [License](#license)

## Workflows

### Convention Commits

A workflow for reporting the usage of conventional commits in a GitHub Pull
Request.

```yaml
name: Conventional Commits

on:
  pull_request:

permissions:
  pull-requests: write
  contents: read

jobs:
  conventional-commits:
    name: Conventional Commits
    uses: greenbone/workflows/.github/workflows/conventional-commits.yml@main
```

Inputs:

| Name | Description | |
|------|-------------|-|
| ignore-actors | A comma separated list of users to ignore PRs from | Optional |

### CI Python

A workflow to lint, test and check Python projects.

```yaml
name: Check Python project

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  lint-and-test:
    strategy:
      matrix:
        python-version:
            - "3.9"
            - "3.10"
            - "3.11"

    name: Lint and test
    uses: greenbone/workflows/.github/workflows/ci-python.yml@main
    with:
      lint-packages: my-python-package
      python-version: ${{ matrix.python-version }}
```

Inputs:

| Name | Description | |
|------|-------------|-|
| lint-packages | Names of the Python packages to be linted | |
| mypy | Check types with mypy | Optional (default: true) |
| mypy-arguments | Additional arguments for mypy | Optional |
| python-version | Python version to use | Optional (default: `"3.10"`) |
| test-command | Command to run the unit tests | Optional (default: `"python -m unittest -v"`) |

### Deploy on PyPI

A workflow to deploy a Python package on [PyPI](https://www.pypi.org).

```yml
name: Deploy on PyPI

on:
  release:
    types: [created]

jobs:
  deploy:
    uses: greenbone/workflows/.github/workflows/deploy-pypi.yml@main
    secrets: inherit
```

Secrets:

| Name | Description | |
|------|-------------|-|
| PYPI_TOKEN | Token with permissions to upload the package to PyPI | Required |

### Codecov Python

Calculate coverage and upload it to to [codecov.io](https://codecov.io).

```yml
name: Code Coverage

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  codecov:
    name: Upload coverage to codecov.io
    uses: greenbone/workflows/.github/workflows/codecov-python.yml@main
    secrets: inherit
```

Secrets:

| Name | Description | |
|------|-------------|-|
| CODECOV_TOKEN | Token for uploading coverage reports to codecov.io | Optional |

Inputs:

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |

### Release Python

A workflow to create GitHub releases for Python projects.

```yml
name: Release Python package

on:
  pull_request:
    types: [closed]
  workflow_dispatch:

jobs:
  release:
    name: Create a new CalVer release
    uses: greenbone/workflows/.github/workflows/release-python.yml@main
    secrets: inherit
```

Secrets:

| Name | Description | |
|------|-------------|-|
| GREENBONE_BOT | Username of the Greenbone Bot Account | Required |
| GREENBONE_BOT_TOKEN | Token for creating a GitHub release | Required |
| GREENBONE_BOT_MAIL | Email Address of the Greenbone Bot Account for git commits | Required |
| GPG_KEY | GPG key to sign the release files | Optional |
| GPG_FINGERPRINT | Fingerprint of the GPG key | Required if `GPG_KEY` is set |
| GPG_PASSPHRASE | Passphrase for the GPG key | Required if `GPG_KEY` is set |

Inputs:

| Name | Description | |
|------|-------------|-|
| release-type | Type of the release | Optional (default: `"calendar"`) |

## Support

For any question on the usage of the workflows please use the
[Greenbone Community Forum](https://forum.greenbone.net/). If you
found a problem with the software, please
[create an issue](https://github.com/greenbone/workflows/issues)
on GitHub.

## Maintainer

This project is maintained by [Greenbone AG](https://www.greenbone.net/).

## License

Copyright (C) 2023 [Greenbone AG](https://www.greenbone.net/)

Licensed under the [GNU General Public License v3.0 or later](LICENSE).
