# sandbox


Experiments with codepipeline and terraform.

Template files are processed via the Terraform templating mechanism.

```
aws.config.template -- Template file for the ~/.aws/config file on each node.
aws.credentials.template -- Template file for the ~/.aws/credentials file on each node.
db.template.yml -- Template for the db.yml file installed to ~/.vail/db.yml on each node.
vail.template.yml -- Template for ~/.vail/vail.yml installed to each node.
```

Other files:
```
start.sh -- vail startup script installed on each node
stop.sh -- vail shutdown script installed on each node
```
