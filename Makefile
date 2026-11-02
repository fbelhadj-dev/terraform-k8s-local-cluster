.PHONY: build destroy rebuild

build:
	terraform -chdir=terraform init -upgrade
	terraform -chdir=terraform apply
	ansible-playbook ansible/playbooks/site.yaml -v

destroy:
	terraform -chdir=terraform destroy

rebuild:
	$(MAKE) destroy
	$(MAKE) build