# Assignment 3 — CI/CD with GitHub Actions

A Bash diagnostic CLI (`app/app.sh`) with a full local CI/CD pipeline built using GitHub Actions. The pipeline validates the code, runs automated tests, and builds and smoke-tests a Docker image on every push and pull request. No cloud deployment is involved.

## Project Structure

```text
assignment-3/
├── README.md
├── app/
│   └── app.sh              # The application
├── scripts/
│   ├── lint.sh             # File checks + bash -n syntax checks
│   └── build.sh            # Docker build + smoke tests
├── tests/
│   └── test.sh             # Automated test suite
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions pipeline
├── Dockerfile
├── compose.yaml
├── .dockerignore
└── grade.sh                # Local grading script
```

## Requirements

- Linux environment (developed on Ubuntu under WSL)
- Bash
- Docker (for the build and smoke tests)
- Git

## Setup

```bash
git clone https://github.com/Estherjonathan1/Assignment-3.git
cd Assignment-3
chmod +x grade.sh app/*.sh scripts/*.sh tests/*.sh
```

## Usage

```bash
./app/app.sh system-info                # Display system information
./app/app.sh check-host <host>          # Resolve/check a host
./app/app.sh check-port <host> <port>   # Validate port and check TCP connectivity
./app/app.sh help                       # Display usage
```

### Exit codes

| Code | Meaning                                     |
|------|---------------------------------------------|
| 0    | Success                                     |
| 1    | Operational failure (e.g. host unreachable) |
| 2    | Invalid command or input                    |

Valid ports are 1–65535. Invalid commands, missing arguments, non-numeric ports and out-of-range ports return exit code 2.

## Testing

```bash
./scripts/lint.sh     # Checks required files exist and runs bash -n on all scripts
./tests/test.sh       # Runs the test suite
./scripts/build.sh    # Builds the Docker image and runs smoke tests
./grade.sh            # Runs the full local grader
```

The test suite covers: help, system-info, invalid commands, missing host, a valid host, missing port, non-numeric port, and out-of-range ports.

## Docker

```bash
docker build -t devops-tool .
docker run --rm devops-tool help
docker run --rm devops-tool system-info
docker run --rm devops-tool invalid-command   # should exit non-zero
```

## CI/CD Pipeline

The workflow in `.github/workflows/ci.yml` runs on every `push` and `pull_request`, with three jobs in order:

```text
validate  →  test  →  docker
```

1. **validate** runs `scripts/lint.sh`.
2. **test** runs `tests/test.sh`. It only starts after `validate` succeeds (`needs: validate`).
3. **docker** runs `scripts/build.sh` to build the image and smoke-test it. It only starts after `test` succeeds (`needs: test`).

## CI Failure Demonstration

To show that the pipeline catches problems, I created a branch, introduced a deliberate error, and pushed it. All runs are listed at https://github.com/Estherjonathan1/Assignment-3/actions

- **Branch:** `ci-failure-demo`
- **Error introduced:** a deliberate syntax error (commit `e794e5c`)
- **Result:** CI run #3 failed at the `validate` job, so `test` and `docker` did not run.
- **Fix:** removed the syntax error (commit `7d32812`); CI run #4 then passed with all three jobs green.

The branch was merged into `main`, and the final workflow on `main` passes.

## Assumptions

- The scripts run on Linux and do not depend on machine-specific paths or values.
- Docker is installed and the Docker daemon is running when building or running the image.
- Network checks may fail in environments without internet access; this is reported as exit code 1, not a crash.
- No secrets, tokens or keys are stored in the repository.
