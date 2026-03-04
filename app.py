"""
I-Translation Medical Image Converter - Checkpoint 652
Developed by Atantra Das Gupta
"""

import gradio as gr
import tensorflow as tf
import numpy as np
from PIL import Image
import gdown
import os

print("=" * 80)
print("I-TRANSLATION - CHECKPOINT 652")
print("=" * 80)
print(f"TensorFlow: {tf.__version__}")
print(f"NumPy: {np.__version__}")
print(f"Gradio: {gr.__version__}")
print("=" * 80)

# ============================================================================
# MODEL CONFIGURATION - CHECKPOINT 652
# ============================================================================
FILE_IDS = {
    'f': '1dMvJtRBb32BnGI8xc5lJd0U-NbJh90fT',  # Generator F - ckpt 652
    'g': '1nQnBaEyjQyTp3LJ6DF9tfaXrZxIHkROQ',  # Generator G - ckpt 652
    'i': '1QIvFXO0LzDa6IH683OWXkedRAXpcDvk-',  # Generator I - ckpt 652
    'j': '1-Quu4cDJhTpH7RDj-HZ-6c4VsQl1mc6j'   # Generator J - ckpt 652
}

models = {}

# ============================================================================
# CUSTOM LAYERS
# ============================================================================
class InstanceNormalization(tf.keras.layers.Layer):
    """Instance Normalization Layer"""
    
    def __init__(self, epsilon=1e-5, **kwargs):
        super().__init__(**kwargs)
        self.epsilon = epsilon
    
    def build(self, input_shape):
        self.scale = self.add_weight(
            name='scale',
            shape=input_shape[-1:],
            initializer=tf.random_normal_initializer(1., 0.02),
            trainable=True
        )
        self.offset = self.add_weight(
            name='offset',
            shape=input_shape[-1:],
            initializer='zeros',
            trainable=True
        )
        super().build(input_shape)
    
    def call(self, x):
        mean, variance = tf.nn.moments(x, axes=[1, 2], keepdims=True)
        inv = tf.math.rsqrt(variance + self.epsilon)
        normalized = (x - mean) * inv
        return self.scale * normalized + self.offset
    
    def get_config(self):
        config = super().get_config()
        config.update({'epsilon': self.epsilon})
        return config

# ============================================================================
# MODEL BUILDING BLOCKS
# ============================================================================
def downsample(filters, size, apply_norm=True):
    """Downsampling block"""
    initializer = tf.random_normal_initializer(0., 0.02)
    
    result = tf.keras.Sequential()
    result.add(tf.keras.layers.Conv2D(
        filters, size, strides=2, padding='same',
        kernel_initializer=initializer, use_bias=False
    ))
    
    if apply_norm:
        result.add(InstanceNormalization())
    
    result.add(tf.keras.layers.LeakyReLU())
    return result

def upsample(filters, size, apply_dropout=False):
    """Upsampling block"""
    initializer = tf.random_normal_initializer(0., 0.02)
    
    result = tf.keras.Sequential()
    result.add(tf.keras.layers.Conv2DTranspose(
        filters, size, strides=2, padding='same',
        kernel_initializer=initializer, use_bias=False
    ))
    
    result.add(InstanceNormalization())
    
    if apply_dropout:
        result.add(tf.keras.layers.Dropout(0.5))
    
    result.add(tf.keras.layers.ReLU())
    return result

# ============================================================================
# GENERATOR ARCHITECTURE
# ============================================================================
def build_generator():
    """Build U-Net generator"""
    inputs = tf.keras.layers.Input(shape=[64, 64, 1])
    
    # Encoder
    down_stack = [
        downsample(128, 4, apply_norm=False),
        downsample(256, 4),
        downsample(256, 4),
        downsample(256, 4),
        downsample(256, 4),
        downsample(256, 4),
    ]
    
    # Decoder
    up_stack = [
        upsample(256, 4, apply_dropout=True),
        upsample(256, 4, apply_dropout=True),
        upsample(256, 4),
        upsample(256, 4),
        upsample(128, 4),
    ]
    
    initializer = tf.random_normal_initializer(0., 0.02)
    last = tf.keras.layers.Conv2DTranspose(
        1, 4, strides=2, padding='same',
        kernel_initializer=initializer,
        activation='tanh'
    )
    
    x = inputs
    skips = []
    for down in down_stack:
        x = down(x)
        skips.append(x)
    
    skips = reversed(skips[:-1])
    
    for up, skip in zip(up_stack, skips):
        x = up(x)
        x = tf.keras.layers.Concatenate()([x, skip])
    
    x = last(x)
    
    return tf.keras.Model(inputs=inputs, outputs=x)

# ============================================================================
# MODEL LOADING
# ============================================================================
def load_models():
    """Download and load all 4 generator models"""
    print("\n" + "=" * 80)
    print("LOADING CHECKPOINT 652 MODELS FROM GOOGLE DRIVE")
    print("=" * 80)
    
    for name, file_id in FILE_IDS.items():
        print(f"\n[Generator {name.upper()} - Checkpoint 652]")
        
        output_path = f'/tmp/generator_{name}_ckpt652.h5'
        url = f"https://drive.google.com/uc?id={file_id}"
        
        print(f"  📥 Downloading from Google Drive...")
        try:
            gdown.download(url, output_path, quiet=False)
            print(f"  ✅ Downloaded ({os.path.getsize(output_path) / (1024*1024):.1f} MB)")
        except Exception as e:
            print(f"  ❌ Download failed: {e}")
            continue
        
        print(f"  🔧 Building U-Net architecture...")
        model = build_generator()
        
        print(f"  ⚙️ Initializing layers...")
        dummy_input = tf.zeros((1, 64, 64, 1))
        _ = model(dummy_input, training=False)
        
        print(f"  📂 Loading checkpoint 652 weights...")
        try:
            model.load_weights(output_path, by_name=True, skip_mismatch=True)
            models[name] = model
            print(f"  ✅ Generator {name.upper()} (ckpt 652) ready!")
        except Exception as e:
            print(f"  ❌ Weight loading failed: {e}")
        
        if os.path.exists(output_path):
            os.remove(output_path)
            print(f"  🗑️ Cleaned up temporary file")
    
    print("\n" + "=" * 80)
    print(f"✅ SUCCESS: {len(models)}/4 models (checkpoint 652) loaded!")
    print("=" * 80 + "\n")

# ============================================================================
# IMAGE PROCESSING
# ============================================================================
def preprocess_image(img):
    """Preprocess input image"""
    if img is None:
        return None
    
    img_pil = Image.fromarray(img).convert('L')
    img_pil = img_pil.resize((64, 64), Image.LANCZOS)
    img_array = np.array(img_pil).astype(np.float32)
    img_normalized = (img_array / 127.5) - 1.0
    img_tensor = img_normalized.reshape(1, 64, 64, 1)
    
    return img_tensor

def postprocess_image(tensor):
    """Postprocess model output to image"""
    img_array = tensor[0, :, :, 0].numpy()
    img_denorm = ((img_array + 1.0) * 127.5).clip(0, 255).astype(np.uint8)
    img_pil = Image.fromarray(img_denorm, mode='L')
    
    return img_pil

# ============================================================================
# INFERENCE
# ============================================================================
def convert_image(input_image, mode):
    """Convert medical image using all 4 generators"""
    if input_image is None:
        return [None, None, None, None]
    
    if len(models) == 0:
        print("⚠️ No models loaded!")
        return [None, None, None, None]
    
    print(f"\n🔄 Converting image ({mode}) with checkpoint 652...")
    
    input_tensor = preprocess_image(input_image)
    
    results = []
    for gen_name in ['f', 'g', 'i', 'j']:
        if gen_name in models:
            print(f"  Running Generator {gen_name.upper()} (ckpt 652)...")
            output_tensor = models[gen_name](input_tensor, training=False)
            output_image = postprocess_image(output_tensor)
            results.append(output_image)
        else:
            results.append(None)
    
    print(f"✅ Conversion complete!\n")
    return results

# ============================================================================
# GRADIO INTERFACE - MOBILE RESPONSIVE
# ============================================================================
def create_ui():
    """Create mobile-responsive Gradio interface"""
    
    custom_css = """
    .gradio-container {
        max-width: 1200px !important;
        margin: auto !important;
    }
    
    @media (max-width: 768px) {
        .gradio-container {
            padding: 10px !important;
        }
        
        .gr-button {
            font-size: 14px !important;
            padding: 8px 16px !important;
        }
    }
    
    .output-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 10px;
    }
    
    h1 {
        text-align: center;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-size: 2.5em;
        margin-bottom: 0.5em;
    }
    
    @media (max-width: 768px) {
        h1 {
            font-size: 1.8em;
        }
    }
    """
    
    with gr.Blocks(
        title="I-Translation Medical Converter",
        theme=gr.themes.Soft(primary_hue="purple"),
        css=custom_css
    ) as app:
        
        gr.Markdown("""
        # 🏥 I-Translation
        ## Medical Image Translation using QUAD-GAN (Checkpoint 652)
        
        **Developed by Atantra Das Gupta**
        
        Upload a CT or MRI scan and get 4 different AI translations from independent generators.
        """)
        
        with gr.Row():
            with gr.Column(scale=1):
                input_img = gr.Image(
                    label="📤 Upload Medical Image",
                    type="numpy",
                    height=300
                )
                
                mode = gr.Radio(
                    choices=["CT to MRI", "MRI to CT"],
                    label="🔄 Translation Mode",
                    value="CT to MRI"
                )
                
                with gr.Row():
                    convert_btn = gr.Button(
                        "🚀 Convert Image",
                        variant="primary",
                        size="lg"
                    )
                    clear_btn = gr.Button(
                        "🗑️ Clear All",
                        variant="secondary",
                        size="lg"
                    )
            
            with gr.Column(scale=2):
                gr.Markdown("### 🎯 Results from 4 Independent Generators")
                
                with gr.Row():
                    out1 = gr.Image(label="Generator F", height=200)
                    out2 = gr.Image(label="Generator G", height=200)
                
                with gr.Row():
                    out3 = gr.Image(label="Generator I", height=200)
                    out4 = gr.Image(label="Generator J", height=200)
        
        gr.Markdown("""
        ---
        ### 📊 Technical Details
        
        - **Checkpoint:** 652 (out of 6000 epochs)
        - **Architecture:** U-Net with Instance Normalization
        - **Generators:** 4 independent models trained on different data splits
        - **Input/Output:** 64×64 grayscale images
        - **Framework:** TensorFlow 2.15.0
        
        Each generator provides a unique translation perspective based on its training data.
        
        ---
        
        **🔗 Share this app:** `https://i-translation-backend-production-668d.up.railway.app`
        """)
        
        convert_btn.click(
            fn=convert_image,
            inputs=[input_img, mode],
            outputs=[out1, out2, out3, out4]
        )
        
        clear_btn.click(
            fn=lambda: [None] * 5,
            outputs=[input_img, out1, out2, out3, out4]
        )
    
    return app

# ============================================================================
# MAIN
# ============================================================================
if __name__ == "__main__":
    print("\n🔧 Initializing I-Translation (Checkpoint 652)...")
    load_models()
    
    if len(models) > 0:
        print(f"\n✅ {len(models)} models (checkpoint 652) ready for inference")
        print("\n🚀 Launching mobile-responsive Gradio interface...")
        
        app = create_ui()
        app.launch(
            server_name="0.0.0.0",
            server_port=7860,
            share=False
        )
    else:
        print("\n❌ FATAL ERROR: No models loaded. Cannot start application.")
        print("Please check Google Drive links and network connectivity.")
