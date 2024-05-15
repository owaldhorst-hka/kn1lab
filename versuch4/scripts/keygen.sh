#!/bin/bash
rm $HOME/.ssh/id_rsa*
ssh-keygen -N "" -f $HOME/.ssh/id_rsa
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
