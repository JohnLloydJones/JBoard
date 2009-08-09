installation:

Download and install java6. Set the JAVA_HOME environment variable and put $JAVA_HOME/bin in your path.
Download and install jruby (v1.2 or newer). Be sure to set the jruby/bin directory in your path.

Install the required Gems:

jruby -S gem install camping crypt glassfish --include-dependencies

You're done.


From the root directory of the app (where this file is) run the app using run command (./run). point your browser to http://localhost:3000/ and you should see the home page. Log in as admin / password and configure the board settings. Do change the default admin password before you let users loose -- 'password' isn't very secure!

Quick configuration tips:

The glassfish configuration file is in config/glassfish.yml -- here you can, among other things, change the port to something other than 3000.

By default, jboard uses the Derby database and places its files in {user.dir}/.jboard.
To use another database, edit lib/openjpa.properties : there are commented out lines for oracle, postgres and mysql. Comment out the derby line and uncomment the database you want. OpenJpa supports other databases than those four; I haven't tested any others, so you're in uncharted waters. Good luck. For non-derby databases, set the connection url, user name and password in lib/jboard-ds.properties.

JBoard is released under an MIT style license. It uses numerous components that licensed under the Apache 2.0 license. 






