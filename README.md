# Cockroach DB

Terraform and Ansible projects to set up Cockroach DB environment and monitoring tools.

## Prerequisites
* Python 3
* Ansible
* Terraform v0.13
* CentOS / RHEL 7.6 or above

### Orchestration System
This is the linux system used to invoke Terraform and Ansible in order to create the test environment.

#### Orchestration System Setup
1. Install requirements.
    ```
    sudo yum -y install python3 python3-pip git wget unzip
    ```
   
2. Install Terraform according to the [instructions here](https://www.terraform.io/downloads.html)
    ```
    # Download terraform package
    # Note. The scripts are using features only available in version 0.13+
    wget https://releases.hashicorp.com/terraform/0.13.2/terraform_0.13.2_linux_amd64.zip

    # Extract
    unzip terraform_*_linux_amd64.zip

    # Install
    sudo mv ./terraform /usr/bin/
    ```

3. Clone git repository
    ```
    cd ~
    git clone https://github.com/cleeistaken/workload-automation.git
    cd workload-automation
    ````

4. Create a Python virtual environment.
    ```
    # Create virtual environment
    python3 -m venv $HOME/.python3-venv

    # Activate the virtual environment
    source $HOME/.python3-venv/bin/activate

    # (optional) Add VENV to login script
    echo "source $HOME/.python3-venv/bin/activate" >> $HOME/.bashrc
    ```

5. Install required python packages.
    ```
    pip install --upgrade pip
    pip install --upgrade setuptools
    pip install -r python-requirements.txt
    ```

### VM Template
We create a template to address the following requirements and limitations.
1. Need a user account and SSH key for Ansible.
2. Current Terraform (0.13) cannot add a PTP clock device to a VMware vSphere VM. 
3. Current CentOS and RHEL distributions do not include a driver for the PTP device. 

#### VM Template Setup
1. Create a Linux VM with a distribution and version supported by the [VMware PTP driver](https://flings.vmware.com/linux-driver-for-precision-clock-virtual-device#requirements).
  * Set the VM Hardware compatibility to vSphere 7.0 (HW version 17)
  * Add a Precision Clock device to the VM hardware devices and set the source to Host NTP
  * Disable Secure Boot; this prevents from loading the unsigned ptp modules and will not allow the compiled vmw_ptp driver to taint the kernel.

2. Install the required packages for the Terraform customization.
   ```
   sudo yum install open-vm-tools perl
   ```

3. Log into the template VM, download, build, and install the VMware PTP clock driver for the VMware fling site.
   ```
   # Install build requirements
   sudo yum update
   sudo yum group install "Development Tools"
   sudo yum install kernel-devel elfutils-libelf-devel wget
   
   # Reboot
   sudo reboot
   
   # Download sources
   wget https://download3.vmware.com/software/vmw-tools/LinuxDriver_For_Precisions_Clock_Virtual_Device/ptp_vmw-1.0.16123801.zip
   
   # Extract
   unzip ptp_vmw-1.0.16123801.zip
   
   # Build
   cd ptp_vmw-1.0.16123801
   rpmbuild --rebuild ptp_vmw-1.0.16123801-1.src.rpm
   
   # Install vmw_ptp driver
   sudo rpm -ivh $HOME/rpmbuild/RPMS/`uname -m`/ptp_vmw-1.0.16123801-1.`uname -m`.rpm
   
   # Add a user
   sudo adduser vmware
   sudo echo "VMware123" | passwd --stdin vmware
   sudo usermod -aG wheel vmware
   ```

4. From the ***orchestration system*** create and upload an ssh key to the template VM.
   ```
   # Check and create a key if none exits
   if [ ! -f ~/.ssh/id_rsa ]; then
     ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
   fi
   
   # Copy to the template VM
   ssh-copy-id vmware@<ip of the vm>
   
   ```

5. In vSphere convert the VM to a template to prevent any changes.

## Cockroach Cluster Deloyment


### Terraform
1. Initialize Terraform
   ```
   cd ~/workload-automation/cockroach/terraform/
   terraform init
   ```

2. Configure environment settings
   ```
   vi terraform.tfvars
   ```

3. Deploy Cockroach environment
   ```
   terraform apply
   ```

## Ansible
1. Configure settings
   ```
   cd ~/workload-automation/cockroach/ansible/
   vi settings.yml
   vi ansible.cfg
   ```

2. Deploy Cockroach DB 
   ```
   ansible-playbook -i settings.yml -i hosts.yml deploy.yml
   ```

3. Run tests
   ```
   # YCSB test
   ansible-playbook -i settings.yml -i hosts.yml ycsb.yml
   ```
