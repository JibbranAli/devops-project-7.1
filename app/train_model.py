#!/usr/bin/env python3
"""
Train a Random Forest classifier on the Iris dataset.
This script trains the model and saves it as model.pkl
"""

import os
import joblib
import numpy as np
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

def train_model():
    """Train and save the Iris classification model."""
    
    print("="*60)
    print("Training Iris Flower Classification Model")
    print("="*60)
    
    # Load the Iris dataset
    print("\n[1/5] Loading Iris dataset...")
    iris = load_iris()
    X, y = iris.data, iris.target
    
    print(f"  ✓ Dataset loaded: {X.shape[0]} samples, {X.shape[1]} features")
    print(f"  ✓ Classes: {iris.target_names.tolist()}")
    
    # Split into training and testing sets
    print("\n[2/5] Splitting data (80% train, 20% test)...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    print(f"  ✓ Training set: {X_train.shape[0]} samples")
    print(f"  ✓ Test set: {X_test.shape[0]} samples")
    
    # Train the model
    print("\n[3/5] Training Random Forest Classifier...")
    print("  Parameters:")
    print("    - n_estimators: 100")
    print("    - max_depth: 10")
    print("    - random_state: 42")
    
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    print("  ✓ Model trained successfully!")
    
    # Evaluate the model
    print("\n[4/5] Evaluating model performance...")
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n  Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    
    print("\n  Classification Report:")
    print("-" * 60)
    report = classification_report(y_test, y_pred, target_names=iris.target_names)
    print(report)
    
    print("  Confusion Matrix:")
    print("-" * 60)
    cm = confusion_matrix(y_test, y_pred)
    print(cm)
    
    # Feature importance
    print("\n  Feature Importance:")
    print("-" * 60)
    for name, importance in zip(iris.feature_names, model.feature_importances_):
        print(f"    {name:20s}: {importance:.4f}")
    
    # Save the model
    print("\n[5/5] Saving model...")
    
    # Create app directory if it doesn't exist
    os.makedirs("app", exist_ok=True)
    
    model_path = "app/model.pkl"
    joblib.dump(model, model_path)
    
    # Verify the saved model
    file_size = os.path.getsize(model_path) / 1024  # KB
    print(f"  ✓ Model saved to: {model_path}")
    print(f"  ✓ File size: {file_size:.2f} KB")
    
    # Test loading the model
    print("\n  Testing model loading...")
    loaded_model = joblib.load(model_path)
    test_prediction = loaded_model.predict([[5.1, 3.5, 1.4, 0.2]])
    print(f"  ✓ Model loaded successfully!")
    print(f"  ✓ Test prediction: {iris.target_names[test_prediction[0]]}")
    
    print("\n" + "="*60)
    print("✅ Training Complete!")
    print("="*60)
    print(f"\nModel ready for deployment: {model_path}")
    print(f"Accuracy: {accuracy*100:.2f}%")
    print("\nYou can now:")
    print("  1. Build Docker images: docker-compose build")
    print("  2. Start services: docker-compose up -d")
    print("  3. Test API: curl http://localhost:5000/health")
    print()

if __name__ == "__main__":
    train_model()
