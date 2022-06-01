# Disable updates
windows_update_settings 'disable windows update' do
  disable_automatic_updates true
end

# Disable maintenance tasks
registry_key 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance' do
    values [{
      name: 'MaintenanceDisabled',
      type: :dword,
      data: 1,
    }]
    recursive true
    action :create
  end
