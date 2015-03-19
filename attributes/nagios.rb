default['nagiosadmin']['password'] = 'Nagi05#u53r'
default['nagios']['check_role'] = 'nagios-client'
default['nagios_client'] = 'true'

default['nagios']['hostgroups_available'] = ["SJC-1","RIC-1","debian","rhel","windows"]
default['nagios']['services_available'] = ["ssh","dns","http","load","users","space","process"]

default['nagios_hostgroups'] = ["SJC-1","debian"]
override['nagios_hostgroups'] = ["SJC-1","debian"]
default['nagios_servicegroups'] = ["ssh","dns"]
