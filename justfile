get-my-key:
	touch .agekey
	chmod 0600 .agekey
	ssh-add -L | ssh-to-age > .agekey
