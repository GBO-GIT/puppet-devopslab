# Main site.pp

# Define the PATH for the execution of puppet
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/opt/ruby/bin/' ] }

# Import per machine configuration
import '../environnements/*.pp'

node default {}
