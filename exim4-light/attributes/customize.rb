###
# This is the place to override the exim4-light cookbook's default attributes.
#
# Do not edit THIS file directly. Instead, create
# "exim4-light/attributes/customize.rb" in your cookbook repository and
# put the overrides in YOUR customize.rb file.
###

# The following shows how to override the exim4-daemon-light configtype:
#
#normal[:exim][:configtype] = 'satellite'
#normal[:exim][:minimaldns] = 'true'


# Automatically assign smarthost_server from stack configuration
if node[:exim4]['configtype'] == 'satellite' 
  smarthost_instance = node[:exim4][:smarthost_instance]
  normal['exim4']['smarthost_server']  = node[:opsworks][:layers][:mail][:instances][smarthost_instance][:private_ip]
  normal['exim4']['other_hostnames']   = node[:exim4][:mailname]
  normal['exim4']['readhost']          = node[:exim4][:mailname]
  normal['exim4']['hide_mailname']     = true
  normal['exim4']['minimaldns']        = true
  normal['exim4']['localdelivery']     = 'mail_spool'
  normal['exim4']['mailname_in_oh']    = true
end

