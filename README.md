# Bootstrap a Kubernetes cluster in an on-premises environment in minutes

### Guide

1. Step:
Make sure Ansible is installed on your machine
2. Step:
Clone the repo an make sure you correctly fill in your target machines in the `hosts.ini`
3. Step:
Start to configure your cluster configuration based on the sample configuration. (`all.yml`)

```
################# Config #######################
# Option can be leaved empty if the tool is not needed
# (k8s, k3s)
distribution: k3s
# (cilium, flannel, calico)
cni: cilium
# (kube-vip)
ha: kube-vip
# (metallb, purelb, kube-vip, cilium)
lb: purelb
# (nginx-ingress, traefik, haproxy)
ingress: traefik
# (rook, longhorn)
storage:
#################################################
````
here you can choose what tools you want to install.

In addition, please fill in the required information for the tools you selected. 

4. Step
Execute the script with:
`ansible-playbook site.yml`



   
