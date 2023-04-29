# xdmod-cntr
A project to deploy XDMoD on kubernetes/OpenShift.

# temporary removal of xdmod-init container.

In the initial setup of the cluster xdmod-init will run the xdmod-setup to
initialize the databases, create an admin account, set the organization name,
and some other functions.  Here is the link to some documentation of xdmod-setup
use in the configuration of xdmod (https://open.xdmod.org/10.0/configuration.html)

Occasionally xdmod-setup needs to be run to change configuration paramters, for example
adding other accounts not found in the xdmod_init.json.  This can be done manually
by connecting with rsh the xdmod pod (on kubernetes) and running xdmod-setup from
the command line:

    oc rsh <xdmod pod name>
    > xdmod-setup

Additionally, xdmod-init will copy the configuration directory to the database
so anytime a change in confiration is made that modifies the files in
/etc/xdmod, these need to be saved to the database in order to share the configuration
with the kubernetes cron jobs to do the shredding and ingesting of data.  This
can be manually with the following script:

    > python3 file_share_through_db.py

## deploying xdmod on minikube
1) Start minikube (not needed for kubernetes):

    minikube start --driver=hyperkit --extra-config=apiserver.service-node-port-range=1-65535
    kubectl config use-context minikube

2) Create the persistent volumes (may be different for Kubernetes and OpenShift - as this is likely a privileged operation):

    kubectl apply -f ./pv-mariadb.yaml
    kubectl apply -f ./pv-xdmod-conf.yaml
    kubectl apply -f ./pv-xdmod-src.yaml
    kubectl apply -f ./pv-xdmod-data.yaml

## deploying on kubernetes/openshift

3) build the docker files

    for minikube:
        minikube image build --logtostderr -f Dockerfile.moc-xdmod -t moc-xdmod .
        minikube image build --logtostderr -f Dcokerfile.moc-xdmod.dev -t moc-xdmod-dev .

    for openshift
        oc -n xdmod apply -k k8s/xdmod-build
        oc start-build bc-moc-xdmod
        oc start-build bc-moc-xdmod-dev

4)  Set the values in the file xdmod-conf/xdmod_init.json

        {
            "admin_account": {
                "admin_username": "Admin",
                "admin_password": "pass",
                "first_name": "ad",
                "last_name": "min",
                "email_address": "nobody@massopen.cloud"
            },
            "general_settings": {
                "site_address": "localhost",
                "contact_email_address": "nobody@massopen.cloud",
                "center_logo_path": "",
                "enable_dashboard": "off"
            },
            "organization": {
                "name": "Mass Open Cloud",
                "abbreviation": "MOC"
            },
            "database": {
                "host": "mariadb",
                "xdmod_password": "pass",
                "admin_password": "pass"
            },
            "resource": [
                {
                    "name": "testOpenstack",
                    "formal_name": "Test OpenStack",
                    "Auth_URL": "Test's Auth URL",
                    "type": "cloud"
                },
                {
                    "name": "kaizen",
                    "formal_name": "Kaizen OpenStack",
                    "Auth_URL": "kaizen's Auth URL",
                    "type": "cloud"
                }
            ]
        }

5)  create the necessary configmaps/secrets

    kubectl create cm --from-file xdmod_conf/xdmod_init.json cm-xdmod-init-json
    oc create cm --from-file xdmod_conf/xdmod_init.json cm-xdmod-init-json

    kubectl create cm --from-file xdmod_conf/httpd.conf cm-httpd-conf
    oc create cm --from-file xdmod_conf/httpd.conf cm-httpd-conf

    add the secret(s) to the deployment in both the init-2

      spec:
        template:
          spec:
            initContainers:
              - name: xdmod-init-2
                volume_mounts:
                    ...
                    - name vol-[secret name]
                      readOnly: true
                      mountPath "/root/resources/[resource_name]/"
            volumes:
              ...
              - name: vol-[secret name]
                secret:
                  secretName: [secret_name]


6) Create the namespace (project) - use kubectl for minikube, or oc for openshift

   - not needed for the NERC

    kubectl apply -f ./k8s/kube-base/ns-xdmod.yaml

7) Load the project into the namespace

    kubectl -n xdmod apply -k ./k8s/kube-base
    oc -n xdmod apply -k ./k8s/kube-base

8) Add the route

    oc -n xdmod apply -f ./k8s/kube-base/xdmod-route.yaml
