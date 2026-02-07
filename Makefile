deleteLocalBranch:
	git branch -D $(word 2, $(MAKECMDGOALS))

deleteRemoteBranch:
	git push origin --delete $(word 2, $(MAKECMDGOALS))

deleteBranchLocallyAndRemotely:
	git branch -D $(word 2, $(MAKECMDGOALS)) && git push origin --delete $(word 2, $(MAKECMDGOALS))