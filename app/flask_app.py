#!/usr/bin/env python3
"""
Flask REST API for Iris flower classification.
Serves predictions from the trained ML model.
"""

import os
import joblib
import numpy as np
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for Streamlit

# Load the trained model
MODEL_PATH = "app/model.pkl"
model = None

def load_model():
    """Load the trained model."""
    global model
    try:
        model = joblib.load(MODEL_PATH)
        print(f"✓ Model loaded successfully from {MODEL_PATH}")
        return True
    except Exception as e:
        print(f"✗ Error loading model: {e}")
        return False

# Load model on startup
model_loaded = load_model()

# Iris species names
SPECIES_NAMES = ["Setosa", "Versicolor", "Virginica"]

@app.route("/", methods=["GET"])
def home():
    """Home endpoint with API information."""
    return jsonify({
        "service": "Iris Flower Classification API",
        "version": "1.0.0",
        "status": "running",
        "model_loaded": model is not None,
        "endpoints": {
            "predict": "/predict (POST)",
            "health": "/health (GET)",
            "info": "/info (GET)"
        },
        "timestamp": datetime.now().isoformat()
    })

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    return jsonify({
        "status": "healthy" if model is not None else "unhealthy",
        "model_loaded": model is not None,
        "timestamp": datetime.now().isoformat()
    })

@app.route("/info", methods=["GET"])
def info():
    """Model information endpoint."""
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500
    
    return jsonify({
        "model_type": "Random Forest Classifier",
        "n_estimators": model.n_estimators,
        "max_depth": model.max_depth,
        "n_features": model.n_features_in_,
        "n_classes": model.n_classes_,
        "classes": SPECIES_NAMES,
        "features": [
            "sepal_length",
            "sepal_width",
            "petal_length",
            "petal_width"
        ],
        "feature_ranges": {
            "sepal_length": "4.0 - 8.0 cm",
            "sepal_width": "2.0 - 4.5 cm",
            "petal_length": "1.0 - 7.0 cm",
            "petal_width": "0.1 - 2.5 cm"
        }
    })

@app.route("/predict", methods=["POST"])
def predict():
    """
    Make a prediction for iris flower species.
    
    Expected JSON input:
    {
        "sepal_length": 5.1,
        "sepal_width": 3.5,
        "petal_length": 1.4,
        "petal_width": 0.2
    }
    """
    if model is None:
        return jsonify({
            "error": "Model not loaded",
            "message": "Please train the model first"
        }), 500
    
    try:
        # Get JSON data
        data = request.get_json()
        
        if not data:
            return jsonify({
                "error": "No data provided",
                "message": "Please send JSON data with flower measurements"
            }), 400
        
        # Extract features
        required_fields = ["sepal_length", "sepal_width", "petal_length", "petal_width"]
        
        # Check if all required fields are present
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            return jsonify({
                "error": "Missing required fields",
                "missing": missing_fields,
                "required": required_fields
            }), 400
        
        # Prepare features for prediction
        features = np.array([[
            float(data["sepal_length"]),
            float(data["sepal_width"]),
            float(data["petal_length"]),
            float(data["petal_width"])
        ]])
        
        # Validate feature ranges
        if not (4.0 <= features[0][0] <= 8.0):
            return jsonify({"error": "sepal_length must be between 4.0 and 8.0"}), 400
        if not (2.0 <= features[0][1] <= 4.5):
            return jsonify({"error": "sepal_width must be between 2.0 and 4.5"}), 400
        if not (1.0 <= features[0][2] <= 7.0):
            return jsonify({"error": "petal_length must be between 1.0 and 7.0"}), 400
        if not (0.1 <= features[0][3] <= 2.5):
            return jsonify({"error": "petal_width must be between 0.1 and 2.5"}), 400
        
        # Make prediction
        prediction_id = int(model.predict(features)[0])
        prediction_name = SPECIES_NAMES[prediction_id]
        
        # Get prediction probabilities
        probabilities = model.predict_proba(features)[0]
        confidence = float(probabilities[prediction_id])
        
        # Prepare response
        response = {
            "prediction": prediction_name,
            "prediction_id": prediction_id,
            "confidence": round(confidence, 4),
            "probabilities": {
                name: round(float(prob), 4)
                for name, prob in zip(SPECIES_NAMES, probabilities)
            },
            "input": {
                "sepal_length": float(data["sepal_length"]),
                "sepal_width": float(data["sepal_width"]),
                "petal_length": float(data["petal_length"]),
                "petal_width": float(data["petal_width"])
            },
            "timestamp": datetime.now().isoformat()
        }
        
        print(f"Prediction: {prediction_name} (confidence: {confidence:.2%})")
        
        return jsonify(response)
    
    except ValueError as e:
        return jsonify({
            "error": "Invalid input",
            "message": "All measurements must be numbers",
            "details": str(e)
        }), 400
    
    except Exception as e:
        return jsonify({
            "error": "Prediction failed",
            "message": str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({
        "error": "Endpoint not found",
        "message": "Please check the API documentation",
        "available_endpoints": ["/", "/health", "/info", "/predict"]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({
        "error": "Internal server error",
        "message": "Something went wrong on the server"
    }), 500

if __name__ == "__main__":
    print("="*60)
    print("Starting Flask API Server")
    print("="*60)
    print(f"Model loaded: {model is not None}")
    print("Endpoints:")
    print("  GET  /         - API information")
    print("  GET  /health   - Health check")
    print("  GET  /info     - Model information")
    print("  POST /predict  - Make predictions")
    print("="*60)
    
    app.run(host="0.0.0.0", port=5000, debug=False)
