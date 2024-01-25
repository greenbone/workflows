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
  - [Build and push container images to ghcr.io or docker.io](#build-and-push-container-images-to-ghcr-io-or-docker-io)
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
| linter | Linter to use | Optional (default: `"pylint"`) |

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
| linter | Linter to use | Optional (default: `"pylint"`) |

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

| Name       | Description                                          |          |
| ---------- | ---------------------------------------------------- | -------- |
| PYPI_TOKEN | Token with permissions to upload the package to PyPI | Optional |

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

### Build and push 3rd gen container images and related helm chart

A workflow to build and push 3rd gen container images and the related helm chart.
In order to have a reasonable container digest transfer to the helm chart release 
we have to build the container and helm charts in the same workflow.

```yml
name: Build Container Image Builds

on:
  workflow_dispatch:

permissions:
  contents: read
  packages: write
  id-token: write
  pull-requests: write

jobs:
  building:
    name: Build Container Image
    uses: greenbone/workflows/.github/workflows/helm-container-build-push-3rd-gen.yml@main
    with:
      image-url: ${{ vars.IMAGE_REGISTRY }}/${{ github.repository }}
      helm-chart: ${{ github.repository }}
      image-labels: |
        org.opencontainers.image.vendor=Greenbone
        org.opencontainers.image.base.name=alpine/latest
    secrets: inherit
```

Inputs:

| Name | Description | |
|------|-------------|-|
| build-context | Path to image build context. Default is "." | Optional |
| build-docker-file | Path to the docker file. Default is "./Dockerfile" | Optional |
| build-args | Use these build-args for the docker build process. Default is empty | Optional |
| build-secrets | Use these build-secrets for the docker build process. Default is empty | Optional |
| build-secret-greenbonebot | Set the GREENBONE_BOT_PACKAGES_READ_TOKEN as image build secret. Default is false | Optional |
| helm-chart | The name of the helm chart to update. If not set, no chart update will be done. Default is empty | Optional |
| init-container | Update the tag from an init container. Set the parent key from the values.yaml. Default is empty | Optional |
| init-container-digest| The init container digest for the helm chart tag. Default is empty | Optional |
| image-labels | Image labels. | Required |
| image-url | Image url/name without registry. | Required |
| image-platforms | Image platforms to build for. Default is "linux/amd64" | Optional |
| use-greenbonebot | Use the greenbonebot token as registry login. Default is false | Optional |
| notify | Enable mattermost notify. Default is true  | Optional |
| scout | Enable docker scout sbom. Default is false  | Optional |

Outputs:

| Name | Description |
|------|-------------|
| digest | The container digest. |

### Notify Mattermost Feed Deployment

Reusable workflow designed for the feed delivery pipeline.

```yml
name: Notify Mattermost Feed Deployment

on:
  workflow_dispatch:

permissions:
  contents: read
  packages: write
  id-token: write

jobs:
  building:
    name: Build Container Image
    uses: greenbone/workflows/.github/workflows/helm-container-build-push-3rd-gen.yml@main
    ...

  building2:
    name: Build Container Image
    uses: greenbone/workflows/.github/workflows/helm-container-build-push-3rd-gen.yml@main
    ...

  notify:
    needs:
      - building
      - building2
    # ignore cancelled workflows
    if: ${{ !cancelled() }}
    uses: greenbone/workflows/.github/workflows/notify-mattermost-feed-deployment.yml@main
    with:
      # We need to check several jobs for an failure status
      status: ${{ contains(needs.*.result, 'failure') && 'failure' || 'success' }}
    secrets: inherit
```

Inputs:

| Name | Description | |
|------|-------------|-|
| commit | The commit used by the github checkout action. Default: github.sha | Optional |
| exit-with-status | Exit this job/workflow with the monitored job status. Options: true or false. Default: true | Optional |
| highlight | Mattermost highlight. Default: devops | Optional |
| status | The monitored job, job status. | Required |

### Notify Mattermost 3rd Gen deployment

Reusable workflow designed for the 3rd gen deployment pipeline.

```yml
name: Notify Mattermost 3rd gen

on:
  workflow_dispatch:

permissions:
  contents: read
  packages: write
  id-token: write

jobs:
  building:
    name: Build Container Image
    uses: greenbone/workflows/.github/workflows/helm-container-build-push-3rd-gen.yml@main
    ...

  building2:
    name: Build Container Image
    uses: greenbone/workflows/.github/workflows/helm-container-build-push-3rd-gen.yml@main
    ...

  notify:
    needs:
      - building
      - building2
    # ignore cancelled workflows
    if: ${{ !cancelled() }}
    uses: greenbone/workflows/.github/workflows/notify-mattermost-3rd-gen@main
    with:
      # We need to check several jobs for an failure status
      status: ${{ contains(needs.*.result, 'failure') && 'failure' || 'success' }}
    secrets: inherit
```

Inputs:

| Name | Description | |
|------|-------------|-|
| commit | The commit used by the github checkout action. Default: github.sha | Optional |
| exit-with-status | Exit this job/workflow with the monitored job status. Options: true or false. Default: true | Optional |
| highlight | Mattermost highlight. Default: channel | Optional |
| status | The monitored job, job status. | Required |

### Notify Mattermost QM

Reusable workflow designed for QM.

```yml
name: Notify Mattermost QM

on:
  workflow_dispatch

jobs:
  building:
    ...
  building2:
    ...
  notify:
    needs:
      - building
      - building2
    # ignore cancelled workflows
    if: ${{ !cancelled() }}
    uses: greenbone/workflows/.github/workflows/notify-mattermost-qm@main
    with:
      # We need to check several jobs for an failure status
      status: ${{ contains(needs.*.result, 'failure') && 'failure' || 'success' }}
    secrets: inherit
```

Inputs:

| Name | Description | |
|------|-------------|-|
| commit | The commit used by the github checkout action. Default: github.sha | Optional |
| exit-with-status | Exit this job/workflow with the monitored job status. Options: true or false. Default: true | Optional |
| highlight | Mattermost highlight. Default: channel | Optional |
| status | The monitored job, job status. | Required |

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
