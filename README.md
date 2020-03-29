# Spinning Walrus
[Just spinning it like a Walrus](https://youtu.be/Ckjzh0PC5fA)!
## Description
This project allows to make a custom Linux image for private game servers ready to be deployed on a Linux server/VPS.
All the needed files are already included into the Linux image so this makes the deployment really easy.
## Insights
The project [slim](https://github.com/ottomatica/slim) is used to turn a Docker image into a real bootable Linux image.
Thanks to Docker, it is now fairly easy to build a custom image and modify it later.
Also the program [metadata](https://github.com/linuxkit/linuxkit/blob/master/docs/metadata.md) from [LinuxKit](https://github.com/linuxkit) is used to fetch the configuration needed to start the server for things like the operator and the server name. This metadata/userdata is passed through the API or directly in the user panel if the cloud provider supports it.
## How to build the image
1. Add the secrets environments variables to the file `info.yml`, you may find an example in the file `info.example.yml`.
2. Install slim: https://github.com/ottomatica/slim#installing-slim.
3. Install Docker and KVM/libvirt.
5. Execute `slim build -p kvm -f iso .`.

Additional documentation available here: https://github.com/ottomatica/slim/blob/master/README.md