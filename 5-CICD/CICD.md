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

