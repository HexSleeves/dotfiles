set dotenv-load := false
set export := true

justfile := justfile_directory() + "/.justfiles/distrobox.justfile"

[private]
@default:
    just --justfile {{ justfile }} --list

[private]
@fmt:
    just --justfile {{ justfile }} --fmt

[group("distrobox")]
@migrate-fedora-apps target="fedora-dev":
    ~/.local/bin/setup-fedora-dev-apps {{ target }}

[group("distrobox")]
@list:
    distrobox list

# --- New: dev container management ---

[group("distrobox")]
@build-dev:
    podman build -t dev-base:latest -f ~/.config/distrobox/dev.Dockerfile ~/.config/distrobox

[group("distrobox")]
@enter container="dev":
    distrobox enter {{ container }}

[group("distrobox")]
@scaffold project:
    ~/.local/bin/distrobox-scaffold {{ project }}

[group("distrobox")]
@scaffold-with project packages:
    ~/.local/bin/distrobox-scaffold {{ project }} --packages "{{ packages }}"

[group("distrobox")]
@generate-entry container="dev":
    distrobox generate-entry {{ container }}
