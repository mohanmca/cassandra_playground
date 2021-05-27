# Dockerd commands

* dockerd --storage-opt lcow.kernel=kernel.efi

# turn off all wsl instances such as docker-desktop
wsl --shutdown
notepad "$env:USERPROFILE/.wslconfig"

```.wslconfig
[wsl2]
memory=3GB   # Limits VM memory in WSL 2 up to 3GB
processors=4 # Makes the WSL 2 VM use two virtual processors
```

https://itnext.io/wsl2-tips-limit-cpu-memory-when-using-docker-c022535faf6f