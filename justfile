get-my-key:
	chmod 0600 ./.agekey
	ssh-add -L | ssh-to-age > ./.agekey
