# docker
Centralized build of dockerimages used by Kubero

Images: 
- [dispatch](images/dispatch/README.md) trigger kpack builds, wait till the image is built and then deploy it by patching the Kuberoapp CRD with the new image.
- [build](images/build/README.md) build docker images with nixpacks
- [fetch](images/fetch/README.md) fetch the code from a git repository
