#!/usr/bin/env python3
"""
Streamlit web interface for Iris flower classification.
Provides an easy-to-use UI for making predictions.
"""

import streamlit as st
import requests
import json
from datetime import datetime

# Page configuration
st.set_page_config(
    page_title="Iris Flower Classifier",
    page_icon="🌸",
    layout="wide"
)

# API endpoint
API_URL = "http://flask-api:5000"

# Title and description
st.title("🌸 Iris Flower Classification")
st.markdown("""
This application predicts the species of an Iris flower based on its measurements.
Adjust the sliders below and click **Predict** to see the result!
""")

# Sidebar with information
with st.sidebar:
    st.header("ℹ️ About")
    st.markdown("""
    **Iris Dataset**
    
    The Iris dataset contains measurements of 150 flowers from 3 species:
    - 🌸 **Setosa**: Small flowers
    - 🌺 **Versicolor**: Medium flowers
    - 🌻 **Virginica**: Large flowers
    
    **Features:**
    - Sepal Length & Width
    - Petal Length & Width
    
    **Model:**
    - Random Forest Classifier
    - Accuracy: ~97%
    """)
    
    # Check API health
    st.header("🔍 System Status")
    try:
        response = requests.get(f"{API_URL}/health", timeout=2)
        if response.status_code == 200:
            st.success("✅ API is healthy")
        else:
            st.error("❌ API is unhealthy")
    except:
        st.error("❌ Cannot connect to API")

# Main content
col1, col2 = st.columns(2)

with col1:
    st.subheader("📏 Flower Measurements")
    
    # Input sliders
    sepal_length = st.slider(
        "Sepal Length (cm)",
        min_value=4.0,
        max_value=8.0,
        value=5.1,
        step=0.1,
        help="Length of the sepal (outer part of the flower)"
    )
    
    sepal_width = st.slider(
        "Sepal Width (cm)",
        min_value=2.0,
        max_value=4.5,
        value=3.5,
        step=0.1,
        help="Width of the sepal"
    )
    
    petal_length = st.slider(
        "Petal Length (cm)",
        min_value=1.0,
        max_value=7.0,
        value=1.4,
        step=0.1,
        help="Length of the petal (inner part of the flower)"
    )
    
    petal_width = st.slider(
        "Petal Width (cm)",
        min_value=0.1,
        max_value=2.5,
        value=0.2,
        step=0.1,
        help="Width of the petal"
    )
    
    # Predict button
    predict_button = st.button("🔮 Predict Flower Species", type="primary", use_container_width=True)

with col2:
    st.subheader("🎯 Prediction Result")
    
    if predict_button:
        # Prepare data
        data = {
            "sepal_length": sepal_length,
            "sepal_width": sepal_width,
            "petal_length": petal_length,
            "petal_width": petal_width
        }
        
        # Show loading spinner
        with st.spinner("Making prediction..."):
            try:
                # Make API request
                response = requests.post(
                    f"{API_URL}/predict",
                    json=data,
                    headers={"Content-Type": "application/json"},
                    timeout=5
                )
                
                if response.status_code == 200:
                    result = response.json()
                    
                    # Display prediction
                    prediction = result["prediction"]
                    confidence = result["confidence"]
                    
                    # Emoji for each species
                    emoji_map = {
                        "Setosa": "🌸",
                        "Versicolor": "🌺",
                        "Virginica": "🌻"
                    }
                    
                    # Color for each species
                    color_map = {
                        "Setosa": "#FF6B6B",
                        "Versicolor": "#4ECDC4",
                        "Virginica": "#FFE66D"
                    }
                    
                    emoji = emoji_map.get(prediction, "🌸")
                    color = color_map.get(prediction, "#4ECDC4")
                    
                    # Success message
                    st.success(f"### {emoji} {prediction}")
                    st.metric("Confidence", f"{confidence*100:.2f}%")
                    
                    # Show all probabilities
                    st.markdown("#### Probabilities:")
                    probabilities = result["probabilities"]
                    
                    for species, prob in probabilities.items():
                        st.progress(prob, text=f"{species}: {prob*100:.2f}%")
                    
                    # Show input summary
                    with st.expander("📊 Input Summary"):
                        st.json(result["input"])
                    
                    # Show timestamp
                    st.caption(f"Prediction made at: {result['timestamp']}")
                    
                else:
                    error_data = response.json()
                    st.error(f"❌ Error: {error_data.get('error', 'Unknown error')}")
                    st.write(error_data.get('message', ''))
            
            except requests.exceptions.ConnectionError:
                st.error("❌ Cannot connect to API. Please check if the Flask API is running.")
            except requests.exceptions.Timeout:
                st.error("❌ Request timed out. The API might be overloaded.")
            except Exception as e:
                st.error(f"❌ An error occurred: {str(e)}")
    else:
        st.info("👆 Adjust the measurements and click **Predict** to see the result!")
        
        # Show example predictions
        st.markdown("#### 📝 Example Measurements:")
        
        examples = {
            "🌸 Setosa": {
                "sepal_length": 5.1,
                "sepal_width": 3.5,
                "petal_length": 1.4,
                "petal_width": 0.2
            },
            "🌺 Versicolor": {
                "sepal_length": 6.0,
                "sepal_width": 2.9,
                "petal_length": 4.5,
                "petal_width": 1.5
            },
            "🌻 Virginica": {
                "sepal_length": 6.5,
                "sepal_width": 3.0,
                "petal_length": 5.2,
                "petal_width": 2.0
            }
        }
        
        for species, measurements in examples.items():
            with st.expander(species):
                st.json(measurements)

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center'>
    <p>Made with ❤️ using Streamlit and Flask</p>
    <p>Powered by scikit-learn Random Forest Classifier</p>
</div>
""", unsafe_allow_html=True)
