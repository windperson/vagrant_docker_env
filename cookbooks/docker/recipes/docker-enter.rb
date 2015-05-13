service 'docker' do
    action :start
    not_if 'service docker status | grep running'
end

bash 'install-nsenter' do
  code 'docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter'
  not_if 'test -x /usr/local/bin/nsenter'
end

bash 'remove-install-nsenter-images' do
  code 'docker rmi jpetazzo/nsenter'
end

remote_file "docker-enter-script" do
  source "#{node[:'docker'][:'docker-enter_src']}"
  path "/usr/local/bin/docker-enter"
  mode 0775
end
