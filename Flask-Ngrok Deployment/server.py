from flask import request, jsonify, Flask
from flask_cors import CORS
from flask_ngrok import run_with_ngrok
import torch
import base64
import torch.nn as nn
import torchvision.transforms as transforms
from PIL import Image
from io import BytesIO
from transformers import AutoModelForImageClassification, AutoConfig


app = Flask(__name__)
run_with_ngrok(app)
CORS(app, resources={r"/api/*": {"origins": "*"}})



class CustomPM(nn.Module):
    def __init__(self, num_classes, pretrained_model="facebook/convnextv2-base-1k-224", hidden_size=256):
        super(CustomPM, self).__init__()
        config = AutoConfig.from_pretrained(pretrained_model)
        self.cvnt = AutoModelForImageClassification.from_pretrained(pretrained_model, config=config)        
        for param in self.cvnt.parameters():                # Freeze ConvNeXt-V2 model
            param.requires_grad = False
        original_classifier = self.cvnt.classifier          # Extracting the original classifier layer
        self.cvnt.classifier = nn.Sequential(
            nn.Linear(original_classifier.in_features, hidden_size),
            nn.Dropout(0.2),
            nn.ReLU(),
            nn.Linear(hidden_size, num_classes)
        )        
    def forward(self, images):
        outputs = self.cvnt(images)
        logits = outputs.logits
        return logits
    


model = torch.load(r"C:\Users\NISHIT\Desktop\plant-disease-detection\pdmodel.pt")
mean = [0.485, 0.456, 0.406]
std = [0.229, 0.224, 0.225]
t_image= transforms.Compose([transforms.Resize((224, 224)),transforms.ToTensor(),transforms.Normalize(mean, std)])
class_mapping = {0: 'Apple___Apple_scab', 1: 'Apple___Black_rot', 2: 'Apple___Cedar_apple_rust', 3: 'Apple___healthy', 4: 'Blueberry___healthy', 5: 'Cherry___Powdery_mildew', 6: 'Cherry___healthy', 7: 'Corn___Cercospora_leaf_spot Gray_leaf_spot', 8: 'Corn___Common_rust', 9: 'Corn___Northern_Leaf_Blight', 10: 'Corn___healthy', 11: 'Grape___Black_rot', 12: 'Grape___Esca_(Black_Measles)', 13: 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)', 14: 'Grape___healthy', 15: 'Orange___Haunglongbing_(Citrus_greening)', 16: 'Peach___Bacterial_spot', 17: 'Peach___healthy', 18: 'Pepper,_bell___Bacterial_spot', 19: 'Pepper,_bell___healthy', 20: 'Potato___Early_blight', 21: 'Potato___Late_blight', 22: 'Potato___healthy', 23: 'Raspberry___healthy', 24: 'Soybean___healthy', 25: 'Squash___Powdery_mildew', 26: 'Strawberry___Leaf_scorch', 27: 'Strawberry___healthy', 28: 'Tomato___Bacterial_spot', 29: 'Tomato___Early_blight', 30: 'Tomato___Late_blight', 31: 'Tomato___Leaf_Mold', 32: 'Tomato___Septoria_leaf_spot', 33: 'Tomato___Spider_mites Two-spotted_spider_mite', 34: 'Tomato___Target_Spot', 35: 'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 36: 'Tomato___Tomato_mosaic_virus', 37: 'Tomato___healthy'}
num_classes = 38



@app.route("/detectPlantDisease", methods=["POST"])
def detectPlantDisease():
    encoded_string = request.get_json()["b64EncodedImgString"]
    decoded_data = base64.b64decode(encoded_string)
    image = Image.open(BytesIO(decoded_data)).convert("RGB")
    image = t_image(image)
    image = image.unsqueeze(0)
    output = model(image.cuda())
    _, predicted_class = torch.max(output, 1)
    predicted_class_name = class_mapping.get(predicted_class.item(), 'Unknown Class')
    return jsonify({"predictedDisease": predicted_class_name}), 200


if __name__ == "__main__":
    app.run()
