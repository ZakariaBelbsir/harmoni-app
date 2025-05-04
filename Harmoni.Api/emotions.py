import datetime
import joblib
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
import re
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import (accuracy_score, classification_report, confusion_matrix,
                             roc_curve, auc, mean_absolute_percentage_error,
                             mean_absolute_error)
from sklearn.tree import DecisionTreeClassifier
from sklearn.naive_bayes import MultinomialNB, ComplementNB
from sklearn.svm import LinearSVC
from sklearn.preprocessing import label_binarize
from itertools import cycle
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader, TensorDataset

# Import the EmotionClassifier class
from EmotionClassifier import EmotionClassifier

# Record the starting time of the script
script_start_time = datetime.datetime.now()

# Check for GPU availability for PyTorch
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Print the script's start time
print(f"Script started at: {script_start_time}")

# Download necessary NLTK resources
nltk.download('stopwords')
nltk.download('wordnet')

# Load the dataset containing text and emotion labels
emotion_data_df = pd.read_csv('../FastAPIProject1/emotions.csv')

# --- Exploratory Data Analysis (EDA) ---
print("--- Exploratory Data Analysis ---")
print(emotion_data_df.info())
print("\n--- Missing Values ---")
print(emotion_data_df.isnull().sum())
print("\n--- Emotion Label Distribution ---")
print(emotion_data_df['label'].value_counts())

# Visualize the distribution of emotion labels
plt.figure(figsize=(8, 6))
sns.countplot(x='label', data=emotion_data_df)
plt.title('Distribution of Emotions')
plt.xlabel('Emotion Label')
plt.ylabel('Number of Samples')
plt.show()

# --- Preprocessing ---
text_lemmatizer = WordNetLemmatizer()
english_stop_words = set(stopwords.words('english'))

# Remove 'not' from stop words to improve model accuracy
if 'not' in english_stop_words:
    english_stop_words.remove('not')


# Function to preprocess text data
def preprocess_text_data(text):
    """
    Preprocesses the input text by converting it to lowercase, removing non-alphanumeric characters,
    splitting it into tokens, lemmatizing the tokens, and removing stop words.

    Args:
        text (str): The text to preprocess.

    Returns:
        str: The preprocessed text.
    """
    text = text.lower()
    text = re.sub(r'[^a-zA-Z\s]', '', text)
    tokens = text.split()
    tokens = [text_lemmatizer.lemmatize(word) for word in tokens if word not in english_stop_words]
    return ' '.join(tokens)


# Apply the preprocessing function to the text data
emotion_data_df['processed_text'] = emotion_data_df['text'].apply(preprocess_text_data)

# Encode the emotion labels
label_encoder = LabelEncoder()
emotion_data_df['label_encoded'] = label_encoder.fit_transform(emotion_data_df['label'])

# --- Split the data into training and testing sets ---
text_data = emotion_data_df['text']
encoded_labels = emotion_data_df['label_encoded']
train_text, test_text, train_labels, test_labels = train_test_split(text_data, encoded_labels, test_size=0.2, random_state=42)

# --- TF-IDF Vectorization ---
tfidf_vectorizer = TfidfVectorizer(max_features=5000, ngram_range=(1, 2), stop_words=list(english_stop_words))

# Fit and transform the training text data, and transform the testing text data
train_tfidf_features = tfidf_vectorizer.fit_transform(train_text)
test_tfidf_features = tfidf_vectorizer.transform(test_text)

# Convert the TF-IDF features to dense arrays
train_dense_features = train_tfidf_features.toarray()
test_dense_features = test_tfidf_features.toarray()


# --- Define PyTorch Neural Network Model ---

# --- Initialize different machine learning models ---
ml_models = {
    "Logistic Regression": LogisticRegression(max_iter=200, solver="saga", n_jobs=-1),
    "Artificial Neural Network": EmotionClassifier(train_dense_features.shape[1], len(label_encoder.classes_)).to(device),
    "Decision Tree": DecisionTreeClassifier(random_state=42),
    "Multinomial Naive Bayes": MultinomialNB(),
    "Complement Naive Bayes": ComplementNB(),
    "Linear SVM": LinearSVC(random_state=42, dual=False, max_iter=200)
}

# --- Convert training and testing data to PyTorch tensors and create DataLoaders ---
training_dataset = TensorDataset(
    torch.FloatTensor(train_dense_features),
    torch.LongTensor(train_labels.values)
)
testing_dataset = TensorDataset(
    torch.FloatTensor(test_dense_features),
    torch.LongTensor(test_labels.values)
)

training_dataloader = DataLoader(training_dataset, batch_size=32, shuffle=True)
testing_dataloader = DataLoader(testing_dataset, batch_size=32, shuffle=False)

# Dictionary to store the results of each model
model_results = {}

# Iterate through each model in the 'ml_models' dictionary
for model_name, model in ml_models.items():
    print(f"Training {model_name}...")
    # Train the Artificial Neural Network if it's the current model
    if model_name == "Artificial Neural Network":
        # Define the loss function (Cross-Entropy Loss for multi-class classification)
        loss_criterion = nn.CrossEntropyLoss()
        # Define the optimizer (Adam optimizer)
        optimizer = optim.Adam(model.parameters())

        # Training loop for a specified number of epochs
        for epoch in range(10):
            # Set the model to training mode
            model.train()
            running_loss = 0.0
            # Iterate over batches of data from the training DataLoader
            for batch_inputs, batch_labels in training_dataloader:
                # Move the input data and labels to the specified device (GPU if available)
                batch_inputs, batch_labels = batch_inputs.to(device), batch_labels.to(device)

                # Zero the gradients from the previous iteration
                optimizer.zero_grad()
                # Perform the forward pass to get the model's output
                model_outputs = model(batch_inputs)
                # Calculate the loss
                loss = loss_criterion(model_outputs, batch_labels)
                # Perform backpropagation to calculate gradients
                loss.backward()
                # Update the model's parameters
                optimizer.step()
                # Accumulate the running loss
                running_loss += loss.item()

            # Print the average loss for the current epoch
            print(f'Epoch {epoch + 1}, Loss: {running_loss / len(training_dataloader):.4f}')

        # Evaluation phase for the Neural Network
        model.eval()
        all_predictions = []
        all_true_labels = []
        with torch.no_grad():
            for batch_inputs, batch_labels in testing_dataloader:
                batch_inputs, batch_labels = batch_inputs.to(device), batch_labels.to(device)
                model_outputs = model(batch_inputs)
                _, predicted_labels = torch.max(model_outputs, 1)  # Get the predicted class labels
                all_predictions.extend(predicted_labels.cpu().numpy())
                all_true_labels.extend(batch_labels.cpu().numpy())

        predictions = np.array(all_predictions)
        true_labels = np.array(all_true_labels)
    else:
        # Train other machine learning models
        model.fit(train_tfidf_features, train_labels)
        predictions = model.predict(test_tfidf_features)
        true_labels = test_labels

    # Store the results for each model
    model_results[model_name] = {
        "accuracy": accuracy_score(true_labels, predictions),
        "report": classification_report(true_labels, predictions, output_dict=True),
        "confusion": confusion_matrix(true_labels, predictions),
        "predictions": predictions
    }

# --- ROC Curve Calculation and Plotting ---
plt.figure(figsize=(10, 8))
binarized_test_labels = label_binarize(test_labels, classes=np.unique(encoded_labels))
num_classes = binarized_test_labels.shape[1]
color_cycle = cycle(['blue', 'red', 'green', 'orange', 'purple', 'brown'])

best_auc = 0
best_model_name = ""
best_model = None

# Iterate through the results of each model to plot ROC curve
for model_name, results in model_results.items():
    if model_name == "Artificial Neural Network":
        ml_models[model_name].eval()
        all_probabilities = []
        with torch.no_grad():
            for batch_inputs, _ in testing_dataloader:
                batch_inputs = batch_inputs.to(device)
                model_outputs = ml_models[model_name](batch_inputs)
                probabilities = torch.softmax(model_outputs, dim=1)  # Get class probabilities
                all_probabilities.extend(probabilities.cpu().numpy())
        y_score = np.array(all_probabilities)
    elif model_name == "Linear SVM":
        #decision_scores = ml_models[model_name].decision_function(test_tfidf_features)
        y_score = ml_models[model_name].decision_function(test_tfidf_features)
        if len(y_score.shape) == 1:
            y_score = np.vstack([-y_score, y_score]).T
    else:
        if hasattr(ml_models[model_name], "predict_proba"):
            y_score = ml_models[model_name].predict_proba(test_tfidf_features)
        else:
            try:
                #decision_scores = ml_models[model_name].decision_function(test_tfidf_features)
                y_score = ml_models[model_name].decision_function(test_tfidf_features)
                if len(y_score.shape) == 1:
                    y_score = np.vstack([-y_score, y_score]).T
                else:
                    y_score = y_score
            except AttributeError:
                y_score = label_binarize(ml_models[model_name].predict(test_tfidf_features), classes=np.unique(encoded_labels))

    fpr = dict()
    tpr = dict()
    roc_auc = dict()
    for i in range(num_classes):
        fpr[i], tpr[i], _ = roc_curve(binarized_test_labels[:, i], y_score[:, i])
        roc_auc[i] = auc(fpr[i], tpr[i])
    fpr["micro"], tpr["micro"], _ = roc_curve(binarized_test_labels.ravel(), y_score.ravel())
    current_auc = auc(fpr["micro"], tpr["micro"])
    plt.plot(fpr["micro"], tpr["micro"], label=f'{model_name} (AUC = {current_auc:.2f})', color=next(color_cycle))
    if current_auc > best_auc:
        best_auc = current_auc
        best_model_name = model_name
        best_model = ml_models[model_name]

plt.plot([0, 1], [0, 1], 'k--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve for Multi-Class Classification')
plt.legend(loc="lower right")
plt.show()

# Save the best model
if best_model_name == "Artificial Neural Network":
    torch.save({
        'model_state_dict': best_model.state_dict(),
        'input_size': train_dense_features.shape[1],
        'num_classes': len(label_encoder.classes_),
        'label_encoder': label_encoder,
        'tfidf_vectorizer': tfidf_vectorizer
    }, 'best_emotion_model.pth')
else:
    joblib.dump({
        'model': best_model,
        'label_encoder': label_encoder,
        'tfidf_vectorizer': tfidf_vectorizer
    }, 'best_emotion_model.joblib')

# Print the name and AUC of the best model
print(f"Best model ({best_model_name}) with AUC = {best_auc:.2f} saved")

# --- WAPE and MAPE Comparison ---
mape_scores = {}
wape_scores = {}
for model_name, results in model_results.items():
    mape = mean_absolute_percentage_error(test_labels, results['predictions'])
    wape = mean_absolute_error(test_labels, results['predictions']) / np.mean(test_labels)
    mape_scores[model_name] = mape
    wape_scores[model_name] = wape

metrics_df = pd.DataFrame({'MAPE': mape_scores, 'WAPE': wape_scores})
print("\nMAPE and WAPE Comparison:")
print(metrics_df)

plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
sns.barplot(x=metrics_df.index, y='MAPE', data=metrics_df)
plt.title('MAPE Comparison')
plt.xticks(rotation=45)
plt.subplot(1, 2, 2)
sns.barplot(x=metrics_df.index, y='WAPE', data=metrics_df)
plt.title('WAPE Comparison')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# --- Confusion Matrix Visualization ---
for model_name, results in model_results.items():
    plt.figure(figsize=(8, 6))
    sns.heatmap(results['confusion'], annot=True, fmt='d', cmap='Blues',
                xticklabels=label_encoder.classes_, yticklabels=label_encoder.classes_)
    plt.title(f'Confusion Matrix - {model_name}')
    plt.xlabel('Predicted')
    plt.ylabel('True')
    plt.show()

# --- Accuracy Visualization ---
accuracy_scores = {model_name: results['accuracy'] for model_name, results in model_results.items()}
accuracy_df = pd.DataFrame({'Accuracy': accuracy_scores})

plt.figure(figsize=(10, 6))
sns.barplot(x=accuracy_df.index, y='Accuracy', data=accuracy_df)
plt.title('Model Accuracy Comparison')
plt.xlabel('Model')
plt.xticks(rotation=45)
plt.ylim(0, 1)
plt.tight_layout()
plt.show()

print(accuracy_df)

# Record the ending time of the script
script_end_time = datetime.datetime.now()
# Print the script's end time
print(f"Script ended at: {script_end_time}")
