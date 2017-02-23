#!/bin/bash

DOMAIN=`ls /etc/letsencrypt/live/`

MDIR=/etc/mysql
LEDIR=/etc/letsencrypt/live/$DOMAIN

#PORT=`netstat -ntlp | grep -c :443`
#if [ "$PORT" -ne 0 ]; then
#echo
#echo PREVIOSLY WE NEED TO STOP WEBSERVER!!
#echo
#exit
#fi

sed -i '/renew_before_expiry/d' /etc/letsencrypt/renewal/$DOMAIN.conf
sed -i -e '1 s/^/renew_before_expiry = 90 days\n/;' /etc/letsencrypt/renewal/$DOMAIN.conf

echo update ssl certificate
certbot renew --tls-sni-01-port 444


#echo gen cert for nginx
#cat $LEDIR/cert.pem $LEDIR/chain.pem > $LEDIR/wschain.pem
#/etc/init.d/nginx reload

echo
echo convert privkey to rsa format and paste to mysql dir
openssl rsa -in /etc/letsencrypt/live/$DOMAIN/privkey.pem -out /etc/mysql/privkey.pem


echo
echo copy LE certs to mysql dir
cp $LEDIR/cert.pem $MDIR/
cp $LEDIR/chain.pem $MDIR/cacert.pem

echo
echo "Please, look in config my.cnf and be sure that following options are:"
echo -n "ssl-ca=/etc/mysql/cacert.pem
ssl-cert=/etc/mysql/cert.pem
ssl-key=/etc/mysql/privkey.pem
"
echo
echo
echo "NOW, NEED TO RESTART MYSQL."
