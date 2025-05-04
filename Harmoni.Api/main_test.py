from unittest.mock import patch  # For mocking dependencies during testing

import pytest  # Python testing framework
import torch  # PyTorch library for tensor computations and neural networks
from fastapi.testclient import TestClient  # Utility for testing FastAPI applications
from sklearn.feature_extraction.text import TfidfVectorizer  # For converting text to numerical vectors
from sklearn.preprocessing import LabelEncoder  # For encoding categorical labels
from torch import nn  # Neural network module in PyTorch

from main import app, preprocess_text_data  # Import the FastAPI app and the preprocess_text function from the main application file


@pytest.fixture
def mock_joblib_model():
    """
    Pytest fixture to create a mock machine learning model and related objects
    as if loaded using joblib. This is used to isolate tests from actual model files.
    """
    # Create a dummy predict method that always returns [0] (representing the first class)
    mock_model = lambda x: [0] * len(x)
    # Create a mock LabelEncoder fitted with some sample emotion labels
    mock_label_encoder = LabelEncoder().fit(['sadness', 'joy'])
    # Create a mock TfidfVectorizer fitted with some sample text
    mock_tfidf = TfidfVectorizer()
    mock_tfidf.fit(['sample text'])
    # Return a dictionary containing the mock model, label encoder, and TF-IDF vectorizer
    return {'model': mock_model, 'label_encoder': mock_label_encoder, 'tfidf_vectorizer': mock_tfidf}


@pytest.fixture
def mock_pytorch_model():
    """
    Pytest fixture to create a mock PyTorch neural network model and related objects.
    This simulates a PyTorch model that could be loaded from a .pth file.
    """
    # Define a simple mock neural network classifier
    class MockClassifier(nn.Module):
        def __init__(self, input_size, num_classes):
            super().__init__()
            self.fc = nn.Linear(input_size, num_classes)  # A single linear layer

        def forward(self, x):
            return torch.softmax(self.fc(x), dim=1)  # Apply softmax for probability distribution

    input_size = 10  # Define a dummy input size for the mock model
    num_classes = 6  # Define the number of output classes for the mock model
    # Instantiate the mock classifier
    mock_model = MockClassifier(input_size, num_classes)
    # Initialize the weights and biases of the linear layer with a constant value (no gradient calculation)
    with torch.no_grad():
        mock_model.fc.weight.data.fill_(0.1)
        mock_model.fc.bias.data.fill_(0.1)

    # Create a mock LabelEncoder fitted with all possible emotion labels
    mock_label_encoder = LabelEncoder().fit(['sadness', 'joy', 'love', 'anger', 'fear', 'surprise'])
    # Create a mock TfidfVectorizer fitted with some sample text
    mock_tfidf = TfidfVectorizer()
    mock_tfidf.fit(['another sample text'])
    # Return a dictionary containing the mock model, label encoder, TF-IDF vectorizer, input size, and number of classes
    return {
        'model': mock_model,
        'label_encoder': mock_label_encoder,
        'tfidf_vectorizer': mock_tfidf,
        'input_size': input_size,
        'num_classes': num_classes
    }


def test_root_endpoint():
    """
    Tests the root endpoint ("/") of the FastAPI application.
    Ensures it returns a 200 status code and the expected JSON response.
    """
    client = TestClient(app)  # Create a test client for interacting with the FastAPI app
    response = client.get("/")  # Send a GET request to the root endpoint
    assert response.status_code == 200  # Assert that the response status code is 200 (OK)
    assert response.json() == {"message": "Emotion Prediction API"}  # Assert that the JSON response is as expected


@patch('joblib.load')  # Mock the joblib.load function to avoid actual file loading
@patch('torch.load')  # Mock the torch.load function to avoid actual file loading
def test_predict_emotion_pytorch_direct_load(mock_torch_load, mock_joblib_load, mock_pytorch_model):
    """
    Tests the /predict_emotion endpoint when the PyTorch model is loaded directly
    (as an nn.Sequential object, although this test creates it directly).
    Mocks the file loading and uses the mock PyTorch model.
    """
    # Simulate direct loading of nn.Sequential by setting the 'model' key in the mock_pytorch_model
    mock_pytorch_model['model'] = nn.Sequential(
        nn.Linear(mock_pytorch_model['input_size'], mock_pytorch_model['num_classes']),
        nn.Softmax(dim=1)
    )
    # Initialize the weights and biases of the linear layer in the mock sequential model
    with torch.no_grad():
        mock_pytorch_model['model'][0].weight.data.fill_(0.1)
        mock_pytorch_model['model'][0].bias.data.fill_(0.1)
    # Configure the mock torch.load to return the mock PyTorch model data
    mock_torch_load.return_value = mock_pytorch_model
    # Configure the mock joblib.load to raise a FileNotFoundError, forcing the PyTorch loading path
    mock_joblib_load.side_effect = FileNotFoundError
    client = TestClient(app)  # Create a test client
    # Send a POST request to the /predict_emotion endpoint with a sample text
    response = client.post("/predict_emotion", json={"text": "I am feeling excited"})
    assert response.status_code == 200  # Assert that the response status code is 200 (OK)
    assert "emotion" in response.json()  # Assert that the "emotion" key exists in the JSON response
    assert "number" in response.json()  # Assert that the "number" key exists in the JSON response


@patch('joblib.load')  # Mock the joblib.load function
@patch('torch.load')  # Mock the torch.load function
def test_predict_emotion_pytorch_state_dict(mock_torch_load, mock_joblib_load, mock_pytorch_model):
    """
    Tests the /predict_emotion endpoint when the PyTorch model is loaded using its state dictionary.
    Mocks the file loading and uses the mock PyTorch model.
    """
    # Configure the mock torch.load to return the mock PyTorch model data
    mock_torch_load.return_value = mock_pytorch_model
    # Configure the mock joblib.load to raise a FileNotFoundError, forcing the PyTorch loading path
    mock_joblib_load.side_effect = FileNotFoundError
    client = TestClient(app)  # Create a test client
    # Send a POST request to the /predict_emotion endpoint with a sample text
    response = client.post("/predict_emotion", json={"text": "I am so angry"})
    assert response.status_code == 200  # Assert that the response status code is 200 (OK)
    assert "emotion" in response.json()  # Assert that the "emotion" key exists in the JSON response
    assert "number" in response.json()  # Assert that the "number" key exists in the JSON response


@patch('joblib.load')  # Mock the joblib.load function
@patch('torch.load')  # Mock the torch.load function
def test_predict_emotion_empty_text(mock_torch_load, mock_joblib_load, mock_joblib_model):
    """
    Tests the /predict_emotion endpoint with an empty input text.
    Uses the mock joblib model for this test.
    """
    # Configure the mock joblib.load to return the mock joblib model data
    mock_joblib_load.return_value = mock_joblib_model
    # Configure the mock torch.load to raise a FileNotFoundError, forcing the joblib loading path
    mock_torch_load.side_effect = FileNotFoundError
    client = TestClient(app)  # Create a test client
    # Send a POST request to the /predict_emotion endpoint with an empty text
    response = client.post("/predict_emotion", json={"text": ""})
    assert response.status_code == 200  # Assert that the response status code is 200 (OK)
    assert "emotion" in response.json()  # Assert that the "emotion" key exists in the JSON response
    assert "number" in response.json()  # Assert that the "number" key exists in the JSON response