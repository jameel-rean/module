#!/bin/bash -v
yum update -y aws*
. /etc/profile.d/aws-apitools-common.sh
# Configure iptables
/sbin/iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE
/sbin/iptables-save > /etc/sysconfig/iptables
# Configure ip forwarding and redirects
echo 1 >  /proc/sys/net/ipv4/ip_forward && echo 0 >  /proc/sys/net/ipv4/conf/eth0/send_redirects
mkdir -p /etc/sysctl.d/
cat <<EOF > /etc/sysctl.d/nat.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.eth0.send_redirects = 0
EOF
# Download nat_monitor.sh and configure
cd /root
wget http://media.amazonwebservices.com/articles/nat_monitor_files/nat_monitor.sh
NAT_ID=
# CloudFormation should have updated the PrivateRouteTable2 by now (due to yum update), however loop to make sure
while [ "$NAT_ID" == "" ]; do
  sleep 60
  NAT_ID=`/opt/aws/bin/ec2-describe-route-tables ${PrivateRouteTable2} -U https://ec2.${Region}.amazonaws.com | grep 0.0.0.0/0 | awk '{print $2;}'`
  #echo `date` "-- NAT_ID=$NAT_ID" >> /tmp/test.log
done
# Update NAT_ID, NAT_RT_ID, and My_RT_ID
sed "s/NAT_ID=/NAT_ID=$NAT_ID/g" /root/nat_monitor.sh > /root/nat_monitor.tmp
sed "s/NAT_RT_ID=/NAT_RT_ID=${PrivateRouteTable2}/g" /root/nat_monitor.tmp > /root/nat_monitor.sh
sed "s/My_RT_ID=/My_RT_ID=${PrivateRouteTable1}/g" /root/nat_monitor.sh > /root/nat_monitor.tmp
sed "s/EC2_URL=/EC2_URL=https:\/\/ec2.${Region}.amazonaws.com/g" /root/nat_monitor.tmp > /root/nat_monitor.sh
sed "s/Num_Pings=3/Num_Pings=${NumberOfPings}/g" /root/nat_monitor.sh > /root/nat_monitor.tmp
sed "s/Ping_Timeout=1/Ping_Timeout=${PingTimeout}/g" /root/nat_monitor.tmp > /root/nat_monitor.sh
sed "s/Wait_Between_Pings=2/Wait_Between_Pings=${WaitBetweenPings}/g" /root/nat_monitor.sh > /root/nat_monitor.tmp
sed "s/Wait_for_Instance_Stop=60/Wait_for_Instance_Stop=${WaitForInstanceStop}/g" /root/nat_monitor.tmp > /root/nat_monitor.sh
sed "s/Wait_for_Instance_Start=300/Wait_for_Instance_Start=${WaitForInstanceStart}/g" /root/nat_monitor.sh > /root/nat_monitor.tmp
mv /root/nat_monitor.tmp /root/nat_monitor.sh
chmod a+x /root/nat_monitor.sh
echo '@reboot /root/nat_monitor.sh > /tmp/nat_monitor.log' | crontab
/root/nat_monitor.sh > /tmp/nat_monitor.log &






