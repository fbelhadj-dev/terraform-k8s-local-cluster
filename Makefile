.PHONY: build destroy

build:
	terraform -chdir=terraform apply
	ansible-playbook ansible/playbooks/site.yaml

destroy:
	terraform -chdir=terraform destroy