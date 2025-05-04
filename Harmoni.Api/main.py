import joblib
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import re
import torch
import torch.nn as nn
from fastapi import FastAPI
from pydantic import BaseModel

# Import the EmotionClassifier class
from EmotionClassifier import EmotionClassifier

# Create a FastAPI instance
app = FastAPI()

# Download necessary NLTK resources
nltk.download('stopwords')
nltk.download('wordnet')

# Initialize lemmatizer and stop words
text_lemmatizer = WordNetLemmatizer()
english_stop_words = set(stopwords.words('english'))


def preprocess_text_data(text):
    """
    Preprocesses the input text by converting it to lowercase, removing non-alphanumeric characters,
    splitting it into tokens, lemmatizing the tokens, and removing stop words.

    Args:
        text (str): The text to preprocess.

    Returns:
        str: The preprocessed text.
    """
    text = text = text.lower()
    text = re.sub(r'[^a-zA-Z\s]', '', text)
    tokens = text.split()
    tokens = [text_lemmatizer.lemmatize(word) for word in tokens if word not in english_stop_words]
    return ' '.join(tokens)


# Load the best model
try:
    model_data = joblib.load('best_emotion_model.joblib')
    ml_model = model_data['model']
    label_encoder = model_data['label_encoder']
    tfidf_vectorizer = model_data['tfidf_vectorizer']
    is_pytorch_model = False
except FileNotFoundError:
    model_data = torch.load('best_emotion_model.pth', map_location=torch.device('cpu'),
                            weights_only=False)
    # Check if the loaded model is a simple nn.Sequential
    if isinstance(model_data, nn.Sequential):
        ml_model = model_data
        is_pytorch_model = True
    else:
        # If it's a custom model, extract parameters and create an instance
        input_size = model_data['input_size']
        num_classes = model_data['num_classes']
        ml_model = EmotionClassifier(input_size, num_classes)
        ml_model.load_state_dict(model_data['model_state_dict'])
        is_pytorch_model = True  # Set the flag

    label_encoder = model_data['label_encoder']
    tfidf_vectorizer = model_data['tfidf_vectorizer']

# Define emotion mapping dictionary
emotion_mapping = {
    0: "sadness",
    1: "joy",
    2: "love",
    3: "anger",
    4: "fear",
    5: "surprise",
}


# Define the request and response models using Pydantic
class EmotionRequest(BaseModel):
    text: str


class EmotionResponse(BaseModel):
    emotion: str
    number: int


# Define the API endpoint for emotion prediction
@app.post("/predict_emotion", response_model=EmotionResponse)
async def predict_emotion(request: EmotionRequest):
    """
    Predicts the emotion of the input text.

    Args:
        request (EmotionRequest): The request containing the text to analyze.

    Returns:
        EmotionResponse: The predicted emotion and its corresponding number.
    """
    processed_text = preprocess_text_data(request.text)
    text_tfidf_features = tfidf_vectorizer.transform([processed_text])

    if is_pytorch_model:
        # Convert TF-IDF features to a PyTorch tensor
        text_tensor = torch.FloatTensor(text_tfidf_features.toarray())
        # Disable gradient calculation for inference
        with torch.no_grad():
            # Get the model's output
            model_outputs = ml_model(text_tensor)
            # Get the predicted class (emotion number)
            _, predicted_class = torch.max(model_outputs, 1)
        emotion_number = predicted_class.item()
    else:
        # For non-PyTorch models, use the predict method
        predicted_class = ml_model.predict(text_tfidf_features)
        emotion_number = predicted_class[0]

    # Map the emotion number to its corresponding label
    emotion_label = emotion_mapping.get(emotion_number, "unknown")
    print(f'Emotion: {emotion_label}, Number: {emotion_number}')
    return EmotionResponse(emotion=emotion_label, number=emotion_number)


# Define the root endpoint
@app.get("/")
async def root():
    """
    Returns a simple message indicating that the API is running.
    """
    return {"message": "Emotion Prediction API"}
