#---------------------------------------------------------------------

# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     30000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    #option                  httplog
    option                  dontlognull
    #option http-server-close
    #option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           5m
    timeout connect         10s
    timeout client          5m
    timeout server          5m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 100000

listen stats
        bind :81
        stats enable
        stats uri /stats
        stats auth stats:DigDes

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
#frontend  main *:5000
#    acl url_static       path_beg       -i /static /images /javascript /stylesheets
#    acl url_static       path_end       -i .jpg .gif .png .css .js

#    use_backend static          if url_static
#    default_backend             app

#######################################################################
################# R I C H   C L I E N T ###############################
#######################################################################

frontend front::Rich_Client:80
        log 127.0.0.1 local4
        mode tcp
        bind *:80
maxconn 100000
        errorfile 503 /etc/haproxy/errors/503/503.http
        acl SyncServer src 192.168.194.12 192.168.194.13 192.168.194.32
        acl SvcServer  src 192.168.194.39
        acl WebServer  src 192.168.194.26 192.168.194.28 192.168.194.17 192.168.194.42 192.168.194.43 192.168.194.44
        use_backend back::Rich_Client_Thin if WebServer
        use_backend back::Rich_Client_ARM if SyncServer
        use_backend back::Rich_Client_SVC if SvcServer
        default_backend back::Rich_Client_Users

backend back::Rich_Client_Users
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type string size 10m expire 120m
        cookie RICHCLIENT insert indirect nocache preserve maxidle 60m
        option httpchk /Docsvision

        server sed-app1.nnov.ru 192.168.194.25:80 check port 80 inter 123 rise 5 fall 2 cookie sed-app1 disabled
        server sed-app2.nnov.ru 192.168.194.27:80 check port 80 inter 123 rise 5 fall 5 cookie sed-app2
        server sed-app3.nnov.ru 192.168.194.16:80 check port 80 inter 123 rise 5 fall 5 cookie sed-app3
        server sed-app4.nnov.ru 192.168.194.45:80 check port 80 inter 123 rise 5 fall 5 cookie sed-app4
        server sed-app5.nnov.ru 192.168.194.46:80 check port 80 inter 123 rise 5 fall 5 cookie sed-app5
        server sed-app6.nnov.ru 192.168.194.47:80 check port 80 inter 123 rise 5 fall 5 cookie sed-app6

backend back::Rich_Client_ARM
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        stick on src
        stick-table type ip size 5m expire 2m
        #cookie RICHCLIENTARM insert indirect nocache preserve maxidle 2m
        option httpchk /Docsvision

        server sed-app1.nnov.ru 192.168.194.25:80 check port 80 inter 116 rise 5 fall 5 disabled
        server sed-app2.nnov.ru 192.168.194.27:80 check port 80 inter 116 rise 5 fall 5
        server sed-app3.nnov.ru 192.168.194.16:80 check port 80 inter 116 rise 5 fall 5
        server sed-app4.nnov.ru 192.168.194.45:80 check port 80 inter 116 rise 5 fall 5
        server sed-app5.nnov.ru 192.168.194.46:80 check port 80 inter 116 rise 5 fall 5
        server sed-app6.nnov.ru 192.168.194.47:80 check port 80 inter 116 rise 5 fall 5

backend back::Rich_Client_SVC
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type ip size 10k expire 2m
        option httpchk /Docsvision

        server sed-app1.nnov.ru 192.168.194.25:80 check port 80 inter 436 rise 5 fall 5 disabled
        server sed-app2.nnov.ru 192.168.194.27:80 check port 80 inter 436 rise 5 fall 5
        server sed-app3.nnov.ru 192.168.194.16:80 check port 80 inter 436 rise 5 fall 5
        server sed-app4.nnov.ru 192.168.194.45:80 check port 80 inter 436 rise 5 fall 5
        server sed-app5.nnov.ru 192.168.194.46:80 check port 80 inter 436 rise 5 fall 5
        server sed-app6.nnov.ru 192.168.194.47:80 check port 80 inter 436 rise 5 fall 5

backend back::Rich_Client_Thin
        log 127.0.0.1 local3
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type ip size 5m expire 5m
        cookie RICHCLIENTTHIN insert indirect nocache preserve maxidle 15m
        option httpchk /Docsvision

        server sed-app1.nnov.ru 192.168.194.25:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app1 disabled
        server sed-app2.nnov.ru 192.168.194.27:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app2
        server sed-app3.nnov.ru 192.168.194.16:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app3
        server sed-app4.nnov.ru 192.168.194.45:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app4
        server sed-app5.nnov.ru 192.168.194.46:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app5
        server sed-app6.nnov.ru 192.168.194.47:80 check port 80 inter 144 rise 5 fall 5 cookie sed-app6

#######################################################################

#######################################################################
########### C O N V E R S I O N    S E R V I C E ######################
#######################################################################

frontend front::Conversion:1000
        mode tcp
        bind *:1000
        acl WebServer  src 192.168.194.26 192.168.194.28 192.168.194.17 192.168.194.42 192.168.194.43 192.168.194.44
        acl AppServer  src 192.168.194.25 192.168.194.27 192.168.194.16 192.168.194.45 192.168.194.46 192.168.194.47
        use_backend back::Conversion_Thin if WebServer
        use_backend back::Conversion_App if AppServer
        default_backend back::Conversion_Users

backend back::Conversion_Users
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type string size 10k expire 120m
        #cookie CONVERSION insert indirect nocache
        option httpchk #/ConversionService.svc

        server sed-app1.nnov.ru 192.168.194.25:1000 check port 1000 inter 123 rise 5 fall 5 disabled
        server sed-app2.nnov.ru 192.168.194.27:1000 check port 1000 inter 123 rise 5 fall 5
        server sed-app3.nnov.ru 192.168.194.16:1000 check port 1000 inter 123 rise 5 fall 5
        server sed-app4.nnov.ru 192.168.194.45:1000 check port 1000 inter 123 rise 5 fall 5
        server sed-app5.nnov.ru 192.168.194.46:1000 check port 1000 inter 123 rise 5 fall 5
        server sed-app6.nnov.ru 192.168.194.47:1000 check port 1000 inter 123 rise 5 fall 5

backend back::Conversion_Thin
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type ip size 10k expire 10m
        option httpchk #/ConversionService.svc

        server sed-app1.nnov.ru 192.168.194.25:1000 check port 1000 inter 144 rise 5 fall 5 disabled
        server sed-app2.nnov.ru 192.168.194.27:1000 check port 1000 inter 144 rise 5 fall 5
        server sed-app3.nnov.ru 192.168.194.16:1000 check port 1000 inter 144 rise 5 fall 5
        server sed-app4.nnov.ru 192.168.194.45:1000 check port 1000 inter 144 rise 5 fall 5
        server sed-app5.nnov.ru 192.168.194.46:1000 check port 1000 inter 144 rise 5 fall 5
        server sed-app6.nnov.ru 192.168.194.47:1000 check port 1000 inter 144 rise 5 fall 5

backend back::Conversion_App
        balance leastconn
        mode http
        #option forwardfor      except 127.0.0.0/8
        #stick on src
        #stick-table type ip size 10k expire 10m
        option httpchk #/ConversionService.svc?wsdl

        server sed-app1.nnov.ru 192.168.194.25:1000 check port 1000 inter 177 rise 5 fall 5 disabled
        server sed-app2.nnov.ru 192.168.194.27:1000 check port 1000 inter 177 rise 5 fall 5
        server sed-app3.nnov.ru 192.168.194.16:1000 check port 1000 inter 177 rise 5 fall 5
        server sed-app4.nnov.ru 192.168.194.45:1000 check port 1000 inter 177 rise 5 fall 5
        server sed-app5.nnov.ru 192.168.194.46:1000 check port 1000 inter 177 rise 5 fall 5
        server sed-app6.nnov.ru 192.168.194.47:1000 check port 1000 inter 177 rise 5 fall 5

#######################################################################

#######################################################################
######### I N T E G R A T I O N    I N T E R F A C E ##################
#######################################################################

frontend front::Integration:8081
        mode tcp
        bind *:8080
        default_backend back::Integration

backend back::Integration
        balance leastconn
        mode http
        option httpchk #/ConversionService.svc

        server sed-service1.nnov.ru 192.168.194.39:8080 check port 8080 inter 123 rise 5 fall 5
        server sed-service2.nnov.ru 192.168.194.56:8080 check port 8080 inter 123 rise 5 fall 5
