# OpenComplAI check

Run [`opencomplai check`](https://github.com/Opencomplai/opencomplai) on a system manifest in your pull
requests. The Action posts the result as one sticky pull request comment, keeps the
`compliance-artifact.json` as a workflow artifact, can upload the SARIF verdict to code scanning,
and fails the job when the check fails.

The Action reports what the check found. It does not certify anything and is not legal advice.

## Usage

```yaml
name: compliance
on: pull_request

permissions:
  contents: read
  pull-requests: write # sticky comment
  security-events: write # only with upload-sarif: "true"

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<40-hex commit SHA> # vN
      - uses: Opencomplai/opencomplai-action@<40-hex commit SHA> # v1
        with:
          manifest: system-manifest.json
```

Pin every `uses:` to a full commit SHA with a trailing version comment. The Action installs
`opencomplai` through `uvx` at one exact release, pinned with `==`, so a run is reproducible.
The `version` input overrides the release the Action was published with.

Signing needs the `sign` input set to `"true"` and a signing key in the job environment
(`SIGNING_KEY_PRIVATE`, from a secret). Without a key the artifact is written unsigned and the
check warns. Passing `--sign` through `args` is strict: a missing key then fails the check.

## Inputs

| Input | Default | Meaning |
|---|---|---|
| `manifest` | `system-manifest.json` | Path to the system manifest |
| `version` | the release pinned in `action.yml` | Exact `opencomplai` release, installed with `uvx --from opencomplai==<version>` |
| `install-from` | empty | Path or package spec that replaces the pinned release (testing a checkout) |
| `with` | empty | Extra `uvx --with` specs, one per line |
| `args` | empty | Extra `opencomplai check` arguments, split on whitespace (for example `--change-context model_retrain`) |
| `comment` | `true` | Post or update one sticky comment on pull request events |
| `upload-sarif` | `false` | Upload the SARIF verdict to code scanning |
| `upload-artifact` | `true` | Upload `compliance-artifact.json` as a workflow artifact (kept 90 days) |
| `artifact-name` | `compliance-artifact-<sha>` | Name of the uploaded artifact, unique within a workflow run |
| `sign` | `false` | Sign the artifact when a signing key is in the environment (`--sign-if-available`) |
| `with-gaps` | `false` | Add the per-article gap report to the artifact (`--with-gaps`) |
| `strict` | `false` | Apply the strict preset: `--with-gaps --scan --fail-on major --require-exemption-record --sign-if-available` |
| `fail-on-error` | `true` | Fail the job when `check` exits non-zero |
| `github-token` | `github.token` | Token for the comment |

`strict: "true"` adds its flags only when you have not already set them. Flags you set through
`args`, `sign` or `with-gaps` win and are never passed twice. The preset adds gates; it never relaxes one.

## Outputs

| Output | Meaning |
|---|---|
| `exit-code` | Exit code of `opencomplai check` |
| `summary-file` | Markdown summary, starting with the sticky comment marker |
| `sarif-file` | SARIF file path, empty when none was written |
| `artifact-file` | Path of `compliance-artifact.json`, empty when none was written |

The Action always completes the `check` step. The job fails in a later step when `fail-on-error` is
`true` and `exit-code` is not `0`; read `exit-code` in a later step to act on the result yourself.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | No gate failure |
| 1 | A control failed (for example a high-risk classification that is not accepted) |
| 2 | Validation failed (bad manifest or missing input) |
| 3 | Policy block (prohibited practice) |
| 4 | Modification trap: halted for human review |

## Permissions

- `contents: read` to check out the repository.
- `pull-requests: write` for the comment. A pull request from a fork has a read-only token: the
  comment is skipped with a warning and the gate result is unchanged.
- `security-events: write` for the SARIF upload.

## Versions

`v1` is a moving tag that always points at the latest 1.x release. Each release of the
`opencomplai` command-line tool is followed by a release of this Action with the new pinned version;
see the [changelog](CHANGELOG.md).

## Licence

AGPL-3.0, see [LICENSE](LICENSE). The code is developed with the
[opencomplai](https://github.com/Opencomplai/opencomplai) project.
