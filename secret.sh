oc create secret docker-registry quay-auth \
--docker-server=quay.io \
--docker-username=ecrookshanks \
--docker-password=<password> \
-n quay-test


oc secrets link default quay-auth --for=pull -n quay-test

NOTE:
If the sync fails, there is a patch command to kick it off:

oc patch application <app-name> -n openshift-gitops --type merge -p '{"operation": {"sync": {"revision": "HEAD"}}}'