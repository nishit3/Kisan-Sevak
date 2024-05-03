from sagemaker import get_execution_role
from sagemaker.pytorch import PyTorchModel
role = get_execution_role()
pytorch_model = PyTorchModel(model_data='s3://innovation-marathon-models/best_crop_FFN.tar.gz', role=role,
                             entry_point='inference.py', py_version='py310', framework_version = '2.1.0')
predictor = pytorch_model.deploy(instance_type='ml.c4.xlarge', initial_instance_count=1)
