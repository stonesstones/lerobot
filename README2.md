# LeRobot Setup and Usage Guide

## Quick Start

### 1. Environment Setup (.env.local)
Create a `.env.local` file in the root directory with the following variables:

```bash
# Docker configuration
PROJECT=your_project_name  # Container name will be {project}-lerobot
IMAGE_TAG=your_image_tag   # Docker image tag

# Dataset configuration
DATASET_PATH=./dataset     # Path where collected data will be stored

# # Hugging Face credentials
# HUGGINGFACE_TOKEN=your_token_here
# HUGGINGFACE_REPO_ID=your_repo_id_here  # Format: username/dataset-name

# # Robot configuration
# ROBOT_TYPE=hsr  # or other robot type
# USE_VIDEOS=true  # or false depending on your needs
```

⚠️ **Important Note about Repo ID**: 
- The repo_id must follow the format `username/dataset-name`
- Make sure you have the necessary permissions to access the repository
- The repository must be created on Hugging Face Hub before use

### 2. Docker Setup and Container Access

1. Build the Docker image:
```bash
./BUILD-DOCKER.SH
```

2. Run the container:
```bash
./RUN-DOCKER.SH
```

3. Access the container and setup:
```bash
cd /home/lerobot
uv sync
```

### 3. Data Management

1. Create cache directory:
```bash
mkdir -p ~/.cache/huggingface/lerobot/data
```

2. Copy datasets to cache:
```bash
# Copy from mounted volume
cp -r /path/to/your/lerobot/dataset ~/.cache/huggingface/lerobot/data/
# ex
cp -r /home/datasets/ ~/.cache/huggingface/lerobot/data/
```

### 4. HSR Robot Specific Setup

For HSR robot compatibility, you need to modify several files to use relative actions:

1. In `lerobot/common/policies/diffusion/modeling_diffusion.py`:
```python
# Change the action key to use relative actions
action_key = "action.relative"  # This ensures the policy uses relative actions
```

2. In `lerobot/common/datasets/utils.py`, the `dataset_to_policy_features` function already handles both `action` and `action.relative`:
```python
elif key == "action" or key == "action.relative":
    type = FeatureType.ACTION
```

3. In `lerobot/common/datasets/factory.py`, the dataset factory handles delta timestamps for both action types:
```python
if key == "action" and cfg.action_delta_indices is not None:
    delta_timestamps[key] = [i / ds_meta.fps for i in cfg.action_delta_indices]
if key == "action.relative" and cfg.action_delta_indices is not None:
    delta_timestamps[key] = [i / ds_meta.fps for i in cfg.action_delta_indices]
```

These changes ensure that:
- The diffusion policy uses relative actions by default
- The dataset loader can handle both absolute and relative actions
- The temporal features (delta timestamps) are properly set for relative actions

### 5. Training Diffusion Policy

1. Convert dataset if needed (for v20 to v21 conversion):（まだこのコマンドを実行しなくても学習できるv2.0データであれば）
```bash
python lerobot/common/datasets/v21/convert_dataset_v20_to_v21.py --repo-id=data/pineapple_pickplace_fps4
```

2. Train the policy:
```bash
python lerobot/scripts/train.py \
    --policy.type=diffusion \
    --dataset.repo_id=data/pineapple_pickplace_fps4 \
    --output_dir=./logs
```

## Additional Resources

- [LeRobot Documentation](https://github.com/huggingface/lerobot)
- [Hugging Face Hub](https://huggingface.co/docs/hub/index)
- [HSR Robot Documentation](https://www.toyota-motor.co.jp/robot/hsr/)