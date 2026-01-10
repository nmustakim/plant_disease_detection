# plant_dd_ai

🌱 PlantDD AI
PlantDD AI is a cross-platform mobile application that leverages on-device artificial intelligence to detect plant diseases from leaf images in real time. The system uses a transfer-learned MobileNetV2 model deployed with TensorFlow Lite, enabling fast and fully offline disease classification directly on the user’s device.
The application allows users to capture or upload leaf images, performs image preprocessing using OpenCV, and generates disease predictions with confidence scores. Based on the diagnosis, PlantDD AI provides actionable disease management and treatment guidance, helping farmers and agricultural practitioners make informed decisions. All prediction records are stored locally using SQLite, with optional cloud integration for model updates and feedback synchronization. Developed using Flutter and Provider, the app follows a modular, maintainable architecture suitable for academic research and real-world deployment.

📁 Project Directory Structure
lib/
├── main.dart                      
├── core/                          
│   ├── constants/                 
│   ├── theme/                     
│   ├── utils/                     
│   └── errors/                    
├── data/                          
│   ├── models/                    
│   └── database/                  
├── services/                      
│   ├── image/                     
│   └── file/                      
├── ml/                            
├── controllers/                   
├── providers/                     
└── presentation/                  
└── screens/                       