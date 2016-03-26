if %w{rhel}.include?(node['platform_family']) and 7 <= node['platform_version'].to_i
  bash 'make-fake-nic-detect-rule' do
    code "ln -s /dev/null /etc/udev/rules.d/70-persistent-net.rules"
  end
end
