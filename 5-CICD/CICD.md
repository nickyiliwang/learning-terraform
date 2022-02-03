# CICD with Github

[Infrastructure diagram](../0-resources/CICD.png)

Steps:
1. Generate personal access token from new github account (expire on Sun, May 1 2022)
2. created new github account: nickyiliwang01
2. git clone git@github.com:derekops/terraform-aws-networking.git
3. remove old .git files
4. init new repo and add files to main branch
5. create new repo, *important: has to follow <terraform-aws-xxx> ie. terraform-aws-networking
6. update the remote and push your files
7. add a VCS provider on terraform workspace dashboard, register an new oauth application (https://github.com/settings/applications/new)
8. once connected the client, create a new workspace and use version control workflow
9. in terraform cloud dashboard, add aws_region as variable, aws creadentials in ENV variable

Publishing a module:
<!--https://stackoverflow.com/questions/18216991/create-a-tag-in-a-github-repository-->
1. Tag your github repo (git tag -a xxx)
2. Create a module in the tf dashboard registry => module

Using the Configuration designer:
1. Add both the compute and networkng modules
2. Add required variables
3. download the main.tf output after config is done

Deployment repo / Control center (tf-control folder)
1. controller main.tf is /deployments/tf-dev/main.tf
2. Any modules(networking, compute) within the organization(nickyilwang) is available to use
3. Setup the providers and tfvars file containing github_token, github_owner, tfe_token

Updateing module repository
1. Change the code in moudle repos
2. push new version with tag + 1 (v1.0.0 => v1.0.1)
3. In the /5-CICD/tf-control/deployments/tf-dev/main.tf
4. reference the new version id
5. 