#!/bin/bash
#Author: Luca Santirocchi
#Version 1

#run every 3rd saturday of the month
#30 21 15-21 * 6

#set cluster in Freez mode
/usr/sbin/clusvcadm -Z SAS-DI
wait $!

#check if share is mounted
SHARE=$(df -kh | grep /dati-di | awk '{print $6 }')

if [[ -z $SHARE ]];
then
     echo "SAS NON è attivo su questo nodo quindi esco!!!"
     exit 0
else
     echo "Verifico se i servizi SAS sono UP...."
fi

#check if the service is up and are 19
UP=$(/bin/su -c "sh /etc/init.d/sas.servers status | grep 'is UP' |  awk '{print $NF }'| wc -l" - sasinst)

#if services up are 19 OK then stop all sas services
if [ $UP -eq 19 ];
then
     echo "I servizi sono UP procedo con lo STOP dei servizi SAS e del LASRMONITOR...."
     /bin/su -c "/dati-di/sas/config/Lev1/sas.servers stop" - sasinst
     wait $!

     echo "Sto STOPPANDO il LASRMONITOR....."
     /bin/su -c "/dati-di/sas/config/Lev1/Applications/SASVisualAnalytics/HighPerformanceConfiguration/LASRMonitor.sh stop" - sasinst
     wait $!

     echo "Tutti i Servizi sono STOPPATI...... procedo con lo START dei servizi SAS e del LASRMONITOR......"
     /bin/su -c "/dati-di/sas/config/Lev1/sas.servers start" - sasinst
     wait $!
     sleep 10

     echo "Servizi SAS UP, procedo con lo START del LASRMONITOR....."
     /bin/su -c "/dati-di/sas/config/Lev1/Applications/SASVisualAnalytics/HighPerformanceConfiguration/LASRMonitor.sh start" - sasinst
     wait $!

     echo "Tutti i SERVIZI SAS e LASRMONITOR SONO UP!!!!! "

else
     echo "I SERVIZI SONO già STOPPATI quindi procedo con lo START dei servizi SAS e del LASRMONITOR...."
     /bin/su -c "/dati-di/sas/config/Lev1/sas.servers start" - sasinst
     wait $!
     sleep 10

     echo " Sto Startando il LASRMONITOR...."
     /bin/su -c "/dati-di/sas/config/Lev1/Applications/SASVisualAnalytics/HighPerformanceConfiguration/LASRMonitor.sh start" - sasinst
     wait $!
     
     echo "Tutti i SERVIZI SAS e LASRMONITOR SONO UP!!!!! "

fi

# check if all services are UP
if [ $UP -eq 19 ];
then
     echo "TUTTI I SERVIZI sono UP!!!"
else
     echo "I SERVIZI NON SONO ATTIVI quindi procedo con lo START dei servizi SAS e del LASRMONITOR...."
     /bin/su -c "/dati-di/sas/config/Lev1/sas.servers start" - sasinst
     wait $!
     sleep 10

     echo " Sto Startando il LASRMONITOR...."
     /bin/su -c "/dati-di/sas/config/Lev1/Applications/SASVisualAnalytics/HighPerformanceConfiguration/LASRMonitor.sh start" - sasinst
     wait $!
     
     echo "Tutti i SERVIZI SAS e LASRMONITOR SONO UP!!!!! "
fi

#set cluster in UNFreez mode and exit
/usr/sbin/clusvcadm -U SAS-DI
wait $!
exit 0
