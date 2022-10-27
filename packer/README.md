# Packer

Packer is use for creating the base image used by VMs. In other words, the OS image with required binaries. In our case, we are using the old way of generating images by creating a VHD. The main reason is because ASE doesn't allow us to copy an Image directly.

## Components

- Scripts -> a set of scripts used by the provisioners during the build
- *.hcl -> packer build templates. Used by packer to generate the vhd.

## Creating an image

1. You'll need to configure the credentials for packer. Basically create the following environment variables:

    ```bash
    export ARM_CLIENT_ID="<SP client id>"
    export ARM_CLIENT_SECRET="<P client password>"
    export ARM_SSH_PASS="<ssh password for accessing the packer vm>"
    export ARM_SUBSCRIPTION_ID="<subscription>"
    export ARM_TENANT_ID="<tenant id>"
    export RESOURCE_GROUP="<resource group>"
    export STORAGE_ACCOUNT="<resource group>"
    ```

2. Create the Image
  
    ```bash
    packer validate vhd.<centos|ubuntu|ubuntu-opentdf>.pkr.hcl
    packer fmt vhd.<centos|ubuntu|ubuntu-opentdf>.pkr.hcl
    packer build vhd.<centos|ubuntu|ubuntu-opentdf>.pkr.hcl
    ```

3. Bring the VHD to the ASX to create an OS image.
