![Greenbone Logo](https://www.greenbone.net/wp-content/uploads/gb_new-logo_horizontal_rgb_small.png)

# Greenbone GitHub Actions Workflows <!-- omit in toc -->

Repository that contains a collection of reusable GitHub Actions workflows for
Greenbone projects

- [Workflows](#workflows)
  - [Convention Commits](#convention-commits)
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
