JBoard is a web based message board application with social networking features.
It is written in Java and JRuby and runs an JEE web container (application server) 
such as Tomcat 6. Persistence is handled by OpenJpa and should be able to connect
to any database supported by OpenJpa.  

Required platform

JEE web container (tested on Tomcat 6)
Java JVM > 1.5 (tested on Java 1.6.0_14)
OpenJpa supported database (tested on Oracle 10g Express 10.2.0.1.0, MySql 5.0.75, Postgres 8.4)

Technologies used:

Java 6
JRuby 1.3
JRuby-Rack 0.94 (connector to app server)
OpenJpa 1.2.1 (ORM / Persistence)
Pico Container (IOC / Dependency Injection)

and the following Ruby gems:

Camping 
Markaby
Crypt

To build from scratch you will require Ant for the jboard.jar file. Building the .WAR file
requires JRuby and the Warbler gem (which includes jruby-rack). The configure.txt file
contains information on how to install and configure JBoard using only the pre-built jboard.war 
file.

JBoard was written by John Lloyd-Jones and has been released under an MIT license.
 


 
 