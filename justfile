#!/usr/bin/env -S just --justfile
# https://github.com/casey/just

bt := '0'

export RUST_BACKTRACE := bt

log := "warn"

export JUST_LOG := log
# git submodule - repo URL + optional local folder name
add-submodule URL *NAME:
    #!/usr/bin/env sh
    if [ -z "{{NAME}}" ]; then
        # Extract repo name from URL if no name provided
        basename=$(basename "{{URL}}" .git)
        git submodule add {{URL}} "roles/${basename}"
        git submodule update --init --recursive
        git add .gitmodules "roles/${basename}"
        git commit -m "Adds ${basename} as a submodule"
    else
        git submodule add {{URL}} "roles/{{NAME}}"
        git submodule update --init --recursive
        git add .gitmodules "roles/{{NAME}}"
        git commit -m "Adds {{NAME}} as a submodule"
    fi

## repo stuff
# optionally use --force to force reinstall all requirements
reqs *FORCE:
	ansible-galaxy install -r requirements.yaml {{FORCE}}

# just vault (encrypt/decrypt/edit)
vault ACTION:
    EDITOR='code --wait' ansible-vault {{ACTION}} group_vars/vault.yaml

initial:
    ansible-playbook -b setup.yml -kK
package:
    ansible-playbook -b package.yml
alias:
    ansible-playbook -b alias.yml
docker:
    ansible-playbook -b docker.yml