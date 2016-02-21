service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action :nothing # only define so that it can be restarted if the config changed
end

template "/etc/haproxy/haproxy.cfg" do
  cookbook "haproxy"
  source "haproxy.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[haproxy]"
end

node[:deploy].each do |application, deploy|
  template "/etc/haproxy/ssl/#{node[:haproxy][:ssl_domain]}.pem" do
    source 'ssl.pem.erb'
    variables :pem => "#{deploy[:ssl_certificate_key]}\n#{deploy[:ssl_certificate]}\n#{deploy[:ssl_certificate_ca]}"
    owner "haproxy"
    group "root"
    mode 0600
    notifies :restart, "service[haproxy]"
    only_if do
      deploy[:ssl_support]
    end
  end
end

execute "echo 'checking if HAProxy is not running - if so start it'" do
  not_if "pgrep haproxy"
  notifies :start, "service[haproxy]"
end

