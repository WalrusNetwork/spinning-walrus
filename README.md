# Spinning Walrus
[Just spin the Walrus!](https://youtu.be/Ckjzh0PC5fA)
## Description
This project allows to make a custom Linux image for private game servers ready to be deployed on a Linux server/VPS.
All the needed files are already included into the Linux image so this makes the deployment really easy.
## Insights
The project [slim](https://github.com/ottomatica/slim) is used to turn a Docker image into a real bootable Linux image.

Thanks to Docker, it is now fairly easy to build a custom image and modify it later.

Also the program [metadata](https://github.com/linuxkit/linuxkit/blob/master/docs/metadata.md) from [LinuxKit](https://github.com/linuxkit) is used to fetch the configuration needed to start the server for things like the operator and the server name. This metadata/userdata is passed through the API or directly in the user panel if the cloud provider supports it.
## Monitoring
### Netdata
The program [Netdata](https://www.netdata.cloud) is available on the port 19999 of each server. To access it you just need to type the ip of the server then followed by the 19999 port in your browser (exemple: unixfox.walrus.gg:19999).
### Shell access (console/SSH)
If you need a shell to the server, you can open the console on Vultr panel or add your SSH key to the authorized_keys file: https://gitlab.com/WalrusNetwork/infrastructure/spinningwalrus/-/blob/master/vm/files/root/.ssh/authorized_keys 
## Metadata/User data
An example file is available here: https://gitlab.com/WalrusNetwork/infrastructure/spinningwalrus/-/blob/master/vm/metadata.json
Explaination of each environment variables:
- `minecraft` script (launch the minecraft server):
  - OP_USERNAME: The username of the op to add
  - OP_UUID: The uuid (example: `02407912-8bbf-4b7b-a34c-a45339841436`) of the op to add
  - SERVERNAME: the server name which gets added to the properties
  - MOTD: The motd of the Minecraft server
  - MAX_PLAYERS: The number of slots to allocate
  - ONLINE_MODE: Disable or enable online mode
  - BUNGEECORD: Disable or enable bungeecord support
- `minecraft-sleep` script (delete the server if no one is using it):
  - SLEEP_MIN: The number of minutes before the server gets deleted.
## How to build the image
1. Add the secrets environments variables to the file `info.yml`, you may find an example in the file `info.example.yml`.
2. Install slim: https://github.com/ottomatica/slim#installing-slim.
3. Install Docker and KVM/libvirt.
5. Execute `slim build -p kvm -f iso .`.

Additional documentation available here: https://github.com/ottomatica/slim/blob/master/README.md