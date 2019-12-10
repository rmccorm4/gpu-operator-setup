# GPU-Operator Setup

This was tested with the following configurations:

**Server**:
* AWS p3.2xlarge instance (1xV100 GPU)
* AWS g4dn.2xlarge instance (1xT4 GPU)

**Software**:
* Ubuntu 18.04
* Docker CE 19.03
* Kubernetes 1.15.6
* Helm 2.15.2

## GPU-Operator Setup

Install GPU-Operator and it's dependencies:

```bash
cd setup/

# Install Docker
sudo ./01-setup-docker.sh

# Install Kubernetes
sudo ./02-setup-k8s.sh

# Install Helm
./03-setup-helm.sh

# Install GPU Operator (Helm Chart)
./04-setup-gpu-operator.sh
```

## Test GPU-Operator Installation

Smoke test of containerized NVIDIA Driver/Runtime with `nvidia-smi`:

```bash
sudo docker run --runtime=nvidia -it nvidia/cuda nvidia-smi

  +-----------------------------------------------------------------------------+
  | NVIDIA-SMI 418.40.04    Driver Version: 418.40.04    CUDA Version: 10.1     |
  |-------------------------------+----------------------+----------------------+
  | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
  | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
  |===============================+======================+======================|
  |   0  Tesla V100-SXM2...  On   | 00000000:00:1E.0 Off |                    0 |
  | N/A   30C    P0    22W / 300W |      0MiB / 16130MiB |      1%      Default |
  +-------------------------------+----------------------+----------------------+
										 
  +-----------------------------------------------------------------------------+
  | Processes:                                                       GPU Memory |
  |  GPU       PID   Type   Process name                             Usage      |
  |=============================================================================|
  |  No running processes found                                                 |
  +-----------------------------------------------------------------------------+

```

Or run a sample TensorFlow Jupyter Notebook:

```bash
# This may take at least 3 minutes to start up
./05-sample-tf-notebook.sh
```

## Notes

Some things to look out for when configuring an AWS Instance:

1. Make sure any necessary ports are exposed. The demo tf-notebook will be launched on port 30001 by default, so make
sure to configure a Security Group to open that port: https://chrisalbon.com/aws/basics/run_project_jupyter_on_amazon_ec2/

2. The Docker container images used by the GPU Operator as well as any applications may take up significant space, so be sure to increase the default storage application from 8GB. I generally go with 100GB to be safe.
