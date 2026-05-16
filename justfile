get-my-key:
	touch .agekey
	chmod 0600 .agekey
	ssh-add -L | ssh-to-age > .agekey

decrypt-user-keys: get-my-key
	#!/usr/bin/env bash

	SOPS_AGE_KEY=$(cat .agekey) sops -d ./nix/users/age_keys.enc.json > ./nix/users/age_keys.json
