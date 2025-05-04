from torch import nn


class EmotionClassifier(nn.Module):
    def __init__(self, input_size, num_classes):
        # Call the constructor of the parent class (nn.Module)
        super(EmotionClassifier, self).__init__()
        # First fully connected layer: input_size features to 256 hidden units
        self.fc1 = nn.Linear(input_size, 256)
        # Dropout layer with a dropout probability of 0.5
        self.dropout1 = nn.Dropout(0.5)
        # Second fully connected layer: 256 hidden units to 128 hidden units
        self.fc2 = nn.Linear(256, 128)
        # Another dropout layer with a dropout probability of 0.5
        self.dropout2 = nn.Dropout(0.5)
        # Third fully connected layer: 128 hidden units to num_classes output units (one for each emotion)
        self.fc3 = nn.Linear(128, num_classes)
        # ReLU activation function
        self.relu = nn.ReLU()

    def forward(self, x):
        # Apply ReLU activation to the output of the first fully connected layer
        x = self.relu(self.fc1(x))
        # Apply dropout
        x = self.dropout1(x)
        # Apply ReLU activation to the output of the second fully connected layer
        x = self.relu(self.fc2(x))
        # Apply dropout
        x = self.dropout2(x)
        # Output layer (no activation function applied here for CrossEntropyLoss)
        x = self.fc3(x)
        return x