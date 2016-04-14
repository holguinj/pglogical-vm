# pglogical-vm
## WORK IN PROGRESS

Sets up two VMs:

  * `master`: running postgresql with pglogical
  * `replica`: running postgresql with pglogical, subscribed to `master`.
  
This currently doesn't work, in the sense that changes to the master DB are not reflected in the replica.
