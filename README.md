
# GlusterFS 

CycleCloud project for GlusterFS.

## Start a GlusterFS Cluster

This repo contains the [cyclecloud project](https://docs.microsoft.com/en-us/azure/cyclecloud/projects).
To get started with GlusterFS:

1. Upload the glusterfs project to a locker `cyclecloud project upload`
1. Import the cluster as a service offering `cyclecloud import_cluster GlusterFS -f glusterfs.txt -t`
1. Add the cluster to your managed cluster list in the CycleCloud UI with the _+add cluster_ button.

_NOTE_ : to avoid race conditions in HA fileserver setup, transient software 
installation failures with recovery are expected.

## Configuration

Nodes in the GlusterFS cluster are configured to have one brick per node. This brick is a RAID array with 8 drives and level 0.  The user can configure the size of these drives and whether
to use premium disk or not, but the quantity is fixed at 8.

The cluster creates the gluster volume from the bricks according to

```gluster volume create $type $level tcp ... {nodes}```

Type can be Distributed, Replicated, and Striped volumes and have requirements about the level see
[docs](https://docs.gluster.org/en/v3/Administrator%20Guide/Setting%20Up%20Volumes/).  These scenarios put restrictions on combinations of values.

| Type        | Properties                    |                          Requirements  |
| ------------ |:----------------------------| :--------------------------------------|
|   replicated | redundant, durable           | cluster size _must be a multiple_ of level |
| distributed  | minimum cost, max scale      |   level ignored                        |
| striped      | high concurrency, large files| cluster size _must equal to_ level          |

The levels will be handled automatically based on the volume type choices.


The GlusterFS nodes are deployed on a single VMSS so will automatically have 
fault tolerance through Availability Sets so replicated volume type offers
a very resilient cluster and is the default.

## Mounting exports

An example of mounting a client to the export is provided in a single-node
[cluster template](templates/glusterfs_client.txt). GlusterFS is a highly-available
service.  Using the cyclecloud cluster namespace, the configuration supplies all
glusterfs nodes as failover targets.  


The following example shows how you would configure a single client to mount
two different GlusterFS clusters by referring to them by their cluster name.

```
    [[[configuration gluster.fs.mounts.example]]]
        mount_point = /mnt/example
        clusterUID = my-gluster-cluster

    [[[configuration gluster.fs.mounts.tools]]]
        mount_point = /mnt/tools
        clusterUID = my-tools-gluster-cluster
```

The client is using the glusterfs blob fuse clients and will automatically move
the mount to a failover node in case of node failure.

## Start a GlusterFS Client

1. Import the cluster as a service offering `cyclecloud import_cluster GlusterFS-client -f examples/glusterfs-client.txt -t`
1. Add the cluster to your managed cluster list in the CycleCloud UI with the _+add cluster_ button.
1. In the GlusterFS Cluster dropdown choose the name of the GlusterFS cluster started in the previous section.

The client logic will choose the primary export from the glusterfs nodes
randomly, and the 

```
[root@myhost ~]$ df
Filesystem           1K-blocks    Used  Available Use% Mounted on
ip-0A000211:/gfsvol 5030694924  104016 5030590908   1% /mnt/example
[root@myhost ~]$ mount
ip-0A000211:/gfsvol on /mnt/example type fuse.glusterfs (rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072)
```

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
