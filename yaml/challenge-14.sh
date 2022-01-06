#!/bin/bash
kubectl get nodes -o jsonpath='{.items[*].status.nodeInfo.osImage}' > /root/allNodes_osImage_45CVB34Ji.txt
