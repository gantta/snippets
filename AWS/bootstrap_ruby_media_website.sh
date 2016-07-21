#https://s3.amazonaws.com/us-east-1-aws-training/self-paced-lab-11/rails-app/spl11-bootstrap.sh

#!/bin/env bash

yum update -y
yum install -y gcc libxml2 libxml2-devel libxslt libxslt-devel
yum install -y ruby-devel sqlite-devel
yum install -y gcc-c++
yum install -y ImageMagick-devel ImageMagick-c++-devel
yum install -y patch
gem install bundler --no-ri --no-rdoc
curl -o /tmp/spl11.tar.gz https://s3.amazonaws.com/us-east-1-aws-training/self-paced-lab-11/rails-app/spl11.tar.gz
tar xfz /tmp/spl11.tar.gz -C /home/ec2-user/
cd /home/ec2-user/spl11/
gem install io-console
/usr/local/bin/bundle install
/usr/local/bin/bundle exec rake db:migrate
cat > /home/ec2-user/spl11/tmp/creds.yml << EOF
region: us-west-2a
access_key: AKIAI33I2HEADBO2PLQQ
secret_key: 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
bucket_name: media-thumbnails
table_name: media-meta-data

EOF
/usr/local/bin/bundle exec bin/rails s -b 0.0.0.0 -p 80

