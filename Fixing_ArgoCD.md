# Instructions for getting ArgoCD to run in an OpenShift Local instance

It runs just fine (mostly), but there are a couple of "gotchas" to look out for.

### First
If creating a namespace, the ArgoCD controller must have rights to that namespace.

I'm not sure if this is required if ArgoCD had to create the namespace, but I have to test more on this.

This can be accomplished by creating a role-binding for the target namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argocd-admin-quay-test
  namespace: quay-test
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops

```
Notice that it's creating in the target namespace, so obviously this is created before the ArgoCD application.

### Second
There is a weird permission thing between ArgoCD UI and OpenShift.  ArgoCD relies on groups that OpenShift does not create.  So, after creating a `local-admin` group and adding my new local admin account into that, I have to modify the actual ArgoCD instance:

```bash
oc edit argocd openshift-gitops -n openshift-gitops
```
In this definition, there is a policy section; the new group needs to be added in the `rbac` section:
```yaml
rbac:
    defaultPolicy: ""
    policy: |
      g, system:cluster-admins, role:admin
      g, cluster-admins, role:admin
      g, local-admin, role:admin

```
After restarting, the `admin` user (as a member of the loca-admin group) will be able to see the correct ArgoCD GUI.