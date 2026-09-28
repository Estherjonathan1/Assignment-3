# Assignment 3 - CI/CD with GitHub Actions

A local CI pipeline for a Bash application. It validates the code, runs tests, and builds/smoke-tests a Docker image. There is no cloud deployment.

## Requirements

- Bash
- Docker
- Docker Compose
- Git

## Setup

    git clone <your-repository-url>
    cd <repository>
    chmod +x app/*.sh scripts/*.sh tests/*.sh

## Usage

    ./app/app.sh system-info
    ./app/app.sh check-host <host>
    ./app/app.sh check-port <host> <port>
    ./app/app.sh help

## Exit codes

| Exit code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | Operational/runtime failure |
| 2 | Invalid command or input |

## Docker

    docker build -t devops-tool .
    docker run --rm devops-tool help
    docker run --rm devops-tool system-info

Or with Docker Compose:

    docker compose run --rm devops-tool help

## Testing

Run the grading script:

    ./grade.sh

Or the individual pieces:

    ./scripts/lint.sh    # checks required files and Bash syntax
    ./tests/test.sh      # 8 tests against app.sh
    ./scripts/build.sh   # builds the image and smoke-tests it

## GitHub Actions

`.github/workflows/ci.yml` runs on every `push` and `pull_request`, with three jobs in order:

    validate -> test -> docker

Each later job uses `needs:` so it only runs if the one before it succeeds.

## CI failure demonstration

A branch was created with a deliberate syntax error, pushed to show the `validate` job failing, then fixed and pushed again to show the workflow passing. See the repository's Actions tab and pull request history for this run.

## Assumptions

- The base image is Alpine Linux 3.20, with `bash`, `iputils` (for `ping`) and `procps` installed.
- An unknown command, or invalid host/port input, is treated as invalid input (exit code 2).
- Network checks may fail in restricted environments that block outbound connections.
