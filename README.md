![Greenbone Logo](https://www.greenbone.net/wp-content/uploads/gb_new-logo_horizontal_rgb_small.png)

# Greenbone GitHub Actions Workflows <!-- omit in toc -->

Repository that contains a collection of reusable GitHub Actions workflows for
Greenbone projects

- [Workflows](#workflows)
  - [Conventional Commits](#conventional-commits)
  - [Check Versioning](#check-versioning)
  - [Lint Python](#lint-python)
  - [Test Python](#test-python)
  - [Typing Python](#typing-python)
  - [CI Python](#ci-python)
  - [Deploy on PyPI](#deploy-on-pypi)
  - [Codecov Python](#codecov-python)
  - [Release Python](#release-python)
  - [Release 3rd Gen](#release-3rd-gen)
  - [Release Cloud](#release-cloud)
  - [Helm Build/Push](#helm-buildpush)
  - [Deploy docs on GitHub Pages](#deploy-docs-on-github-pages)
- [Support](#support)
- [Maintainer](#maintainer)
- [License](#license)

## Workflows

### Conventional Commits

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

### Check Versioning

A workflow to check for consistent versioning in a project.

```yml
name: Check versioning

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  versioning:
    uses: greenbone/workflows/.github/workflows/check-version.yml@main
```

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |

### Lint Python

A workflow to lint Python project via pylint.

```yml
name: Lint Python project

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  linting:
    uses: greenbone/workflows/.github/workflows/lint-python.yml@main
```

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |
| lint-packages | Names of the Python packages to be linted | |

### Test Python

A workflow to run tests of a Python project.

```yml
name: Test Python project

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  linting:
    uses: greenbone/workflows/.github/workflows/test-python.yml@main
```

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |
| test-command | Command to run the unit tests | Optional (default: `"python -m unittest -v"`) |

### Typing Python

A workflow to check the type hints of a Python project via mypy.

```yml
name: Check type hints

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  linting:
    uses: greenbone/workflows/.github/workflows/typing-python.yml@main
```

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |
| mypy-arguments | Additional arguments for mypy | Optional |

### CI Python

A workflow to lint, test and type check Python projects.

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
| python-version | Python version to use | Optional (default: `"3.10"`) |
| lint-packages | Names of the Python packages to be linted | |
| mypy-arguments | Additional arguments for mypy | Optional |
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

### Release 3rd Gen

```yml
name: Release

on:
  pull_request:
    types: [closed]
  workflow_dispatch:
    inputs:
      release-type:
        type: choice
        description: What kind of release do you want to do (pontos --release-type argument)?
        options:
          - alpha
          - patch
          - minor
          - major
          - release-candidate
      release-version:
        type: string
        description: Set an explicit version, that will overwrite release-type. Fails if version is not compliant.

jobs:
  build-and-release:
    name: Create a new release
    uses: greenbone/workflows/.github/workflows/release-3rd-gen.yml@main
    with:
      release-type: ${{ inputs.release-type }}
      release-version: ${{ inputs.release-version }}
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
| release-type | Type of the release | Required if called manually (as `workflow_dispatch`) |
| release-version | An explicit release version. If not set the release version will be determined from the current tag and the release type | Optional |

### Release Cloud

```yml
name: Release

on:
  pull_request:
    types: [closed]
  workflow_dispatch:
    inputs:
      release-type:
        type: choice
        description: What kind of release do you want to do (pontos --release-type argument)?
        options:
          - alpha
          - patch
          - minor
          - major
          - release-candidate
      release-version:
        type: string
        description: Set an explicit version, that will overwrite release-type. Fails if version is not compliant.

jobs:
  build-and-release:
    name: Create a new release
    uses: greenbone/workflows/.github/workflows/release-3rd-gen.yml@main
    with:
      release-type: ${{ inputs.release-type }}
      release-version: ${{ inputs.release-version }}
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
| release-type | Type of the release | Required if called manually (as `workflow_dispatch`) |
| release-version | An explicit release version. If not set the release version will be determined from the current tag and the release type | Optional |
| versioning-scheme | Versioning scheme to use. | Optional (default: `"semver"`) |

### Helm Build/Push

```yaml
name: Helm chart release on tag

on:
  push:
    tags: ["v*"]

jobs:
  release-helm-chart:
    name: Release helm chart
    strategy:
      fail-fast: false
      matrix:
        chart:
          - foo
          - bar
    uses: greenbone/workflows/.github/workflows/helm-build-push.yml@main
    with:
      chart: ${{ matrix.chart }}
    secrets: inherit
```

Secrets:

| Name | Description | |
|------|-------------|-|
| GREENBONE_BOT | Username of the Greenbone Bot Account | Required |
| GREENBONE_BOT_PACKAGES_WRITE_TOKEN | Token to upload packages to ghcr.io | Required |
| GREENBONE_BOT_TOKEN | Token to trigger product helm chart updates | Required |

Inputs:

| Name | Description | |
|------|-------------|-|
| chart | Helm Chart to update | Required |

### Deploy docs on GitHub Pages

A workflow to generate a Python documentation and deploy it on GitHub Pages.

```yml
name: Deploy docs to GitHub Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches:
      - main

  # Allows to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow one concurrent deployment
concurrency:
  group: "docs"
  cancel-in-progress: true

jobs:
  deploy:
    uses: greenbone/workflows/.github/workflows/docs-python.yml@main
```

Inputs:

| Name | Description | |
|------|-------------|-|
| python-version | Python version to use | Optional (default: `"3.10"`) |
| source | Directory containing the sources for the documentation | Optional (default: `"docs"`) |
| build | Directory containing the build of the documentation | Optional (default: `"docs/build/html"`) |
| environment-name | Name of the deployment environment | Optional (default: `"github-pages"`) |

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
