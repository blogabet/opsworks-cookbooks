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
  template "/etc/haproxy/ssl/#{application}.pem" do
    mode 0600
    owner "haproxy"
    source 'ssl.pem.erb'
    variables :ssl => {
      'key' => deploy[:ssl_certificate],
      'crt' => deploy[:ssl_certificate_key],
      'ca' => deploy[:ssl_certificate_ca]
    }
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

