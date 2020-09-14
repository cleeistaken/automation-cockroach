# Cockroach DB

Terraform and Ansible projects to set up Cockroach DB environment and monitoring tools.

## Prerequisites
* Python 3
* Ansible 2.9
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
    git clone https://github.com/cleeistaken/automation-cockroach.git
    cd automation-cockroach
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

#### VM Template Setup
1. Create a Linux VM with a distribution and version supported by the [VMware PTP driver](https://flings.vmware.com/linux-driver-for-precision-clock-virtual-device#requirements).
  * Set the VM Hardware compatibility to vSphere 7.0 (HW version 17)
  * Add a Precision Clock device to the VM hardware devices and set the source to Host NTP
  * Disable Secure Boot; this prevents from loading the unsigned ptp modules and will not allow the compiled vmw_ptp driver to taint the kernel.

2. Install the required packages for the Terraform customization.
   ```
   sudo yum install open-vm-tools perl
   ```

3. From the ***orchestration system*** create and upload a ssh key to the template VM.
   ```
   # Check and create a key if none exits
   if [ ! -f ~/.ssh/id_rsa ]; then
     ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
   fi
   
   # Copy to the template VM
   ssh-copy-id vmware@<ip of the vm>
   
   ```

4. In vSphere convert the VM to a template to prevent any changes.

## Cockroach Cluster Deployment


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
1. Check and configure settings
   ```
   cd ~/automation-cockroach/ansible/
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
   ansible-playbook -i settings.yml -i hosts.yml ycsb-init.yml
   ansible-playbook -i settings.yml -i hosts.yml ycsb-run.yml
   
   # TPCC test
   ansible-playbook -i settings.yml -i hosts.yml tpcc-init.yml
   ansible-playbook -i settings.yml -i hosts.yml tpcc-run.yml
   ```
