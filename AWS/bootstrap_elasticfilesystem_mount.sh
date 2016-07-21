#!/bin/sh

yum -y install httpd php
chkconfig httpd on
/etc/init.d/httpd start
sudo mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-1531f55c.efs.us-east-1.amazonaws.com:/ /var/www/html
cd /var/www/html
wget https://us-west-2-aws-training.s3.amazonaws.com/awsu-spl/spl03-working-elb/static/examplefiles-elb.zip
unzip examplefiles-elb.zip
