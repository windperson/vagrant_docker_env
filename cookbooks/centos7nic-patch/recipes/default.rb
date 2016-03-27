if %w{rhel}.include?(node['platform_family']) and 7 <= node['platform_version'].to_i
  # CentOS box stupid bug:
  # https://github.com/mitchellh/vagrant/issues/2614#issuecomment-108050799
  bash 'make-fake-nic-detect-rule' do
    code "rm /etc/udev/rules.d/70-persistent-net.rules
    && ln -sf /dev/null /etc/udev/rules.d/70-persistent-net.rules"
  end
end
