cat SampleScript.ps1
cat SuperSecretData.md

UserName
Password
AccessKeys
...
OhMy

#Local Only

Get-ChildItem

code .

git init

git status

code SampleScript.ps1

git add SampleScript.ps1

git status

git commit -m 'First commit, add SampleScript and gitignore'

git status

----------------------------

#Remote Repo

git clone https://github.com/jhoughes/FromVMsToKubernetes

cd FromVMsToKubernetes

git log

code README

#Adding a note to say hi from 2023 VMUG Virtual Event

git status

git add .

git status

git commit -m'Hello from the 2023 VMUG Virtual Event'

git status

git push

git status

----------------------------

git clone https://github.com/jhoughes/terraform-vmc-demo

cd terraform-vmc-demo

code .

git branch -a

git checkout create-sddc

git checkout add-nsxt-rules

git checkout create-vm

