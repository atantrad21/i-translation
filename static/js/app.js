// Medical Image Converter - Frontend Logic
// Full upload and conversion functionality

// Global state
let currentFile = null;
let conversionType = 'ct_to_mri';
let currentOutputFilename = null;

// DOM elements
const dropZone = document.getElementById('dropZone');
const fileInput = document.getElementById('fileInput');
const previewSection = document.getElementById('previewSection');
const previewImage = document.getElementById('previewImage');
const fileName = document.getElementById('fileName');
const fileSize = document.getElementById('fileSize');
const convertBtn = document.getElementById('convertBtn');
const cancelBtn = document.getElementById('cancelBtn');
const loadingSpinner = document.getElementById('loadingSpinner');
const resultsSection = document.getElementById('resultsSection');
const ctToMriBtn = document.getElementById('ctToMriBtn');
const mriToCtBtn = document.getElementById('mriToCtBtn');
const newConversionBtn = document.getElementById('newConversionBtn');
const downloadBtn = document.getElementById('downloadBtn');
const shareBtn = document.getElementById('shareBtn');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    checkHealth();
});

function setupEventListeners() {
    // Drop zone events
    dropZone.addEventListener('click', () => fileInput.click());
    dropZone.addEventListener('dragover', handleDragOver);
    dropZone.addEventListener('dragleave', handleDragLeave);
    dropZone.addEventListener('drop', handleDrop);
    
    // File input
    fileInput.addEventListener('change', handleFileSelect);
    
    // Conversion type buttons
    ctToMriBtn.addEventListener('click', () => setConversionType('ct_to_mri'));
    mriToCtBtn.addEventListener('click', () => setConversionType('mri_to_ct'));
    
    // Action buttons
    convertBtn.addEventListener('click', performConversion);
    cancelBtn.addEventListener('click', resetUpload);
    newConversionBtn.addEventListener('click', resetAll);
    downloadBtn.addEventListener('click', downloadResult);
    shareBtn.addEventListener('click', shareResult);
}

async function checkHealth() {
    try {
        const response = await fetch('/health');
        const data = await response.json();
        console.log('✅ Backend health check:', data);
    } catch (error) {
        console.error('❌ Backend health check failed:', error);
        showError('Unable to connect to server. Please refresh the page.');
    }
}

function setConversionType(type) {
    conversionType = type;
    
    // Update button styles
    if (type === 'ct_to_mri') {
        ctToMriBtn.classList.add('active');
        mriToCtBtn.classList.remove('active');
    } else {
        mriToCtBtn.classList.add('active');
        ctToMriBtn.classList.remove('active');
    }
    
    // Reset if file is already selected
    if (currentFile) {
        showInfo(`Conversion type changed to ${type === 'ct_to_mri' ? 'CT → MRI' : 'MRI → CT'}`);
    }
}

function handleDragOver(e) {
    e.preventDefault();
    dropZone.classList.add('drag-over');
}

function handleDragLeave(e) {
    e.preventDefault();
    dropZone.classList.remove('drag-over');
}

function handleDrop(e) {
    e.preventDefault();
    dropZone.classList.remove('drag-over');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        handleFile(files[0]);
    }
}

function handleFileSelect(e) {
    const files = e.target.files;
    if (files.length > 0) {
        handleFile(files[0]);
    }
}

function handleFile(file) {
    // Validate file type
    const validTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/bmp', 'image/tiff', 'application/dicom'];
    const validExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.tiff', '.tif', '.dcm', '.dicom'];
    
    const fileName = file.name.toLowerCase();
    const hasValidExtension = validExtensions.some(ext => fileName.endsWith(ext));
    const hasValidType = validTypes.includes(file.type) || file.type === '' || file.type === 'application/octet-stream';
    
    if (!hasValidExtension && !hasValidType) {
        showError('Please upload a valid image file (DICOM, PNG, JPG, BMP, or TIFF)');
        return;
    }
    
    // Validate file size (max 32MB)
    if (file.size > 32 * 1024 * 1024) {
        showError('File size must be less than 32MB');
        return;
    }
    
    currentFile = file;
    displayPreview(file);
}

function displayPreview(file) {
    const reader = new FileReader();
    
    reader.onload = (e) => {
        previewImage.src = e.target.result;
        fileName.textContent = file.name;
        fileSize.textContent = formatFileSize(file.size);
        previewSection.classList.remove('hidden');
        dropZone.classList.add('border-green-400');
        
        // Scroll to preview
        previewSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    };
    
    reader.readAsDataURL(file);
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

function resetUpload() {
    currentFile = null;
    fileInput.value = '';
    previewSection.classList.add('hidden');
    dropZone.classList.remove('border-green-400');
    previewImage.src = '';
    fileName.textContent = '';
    fileSize.textContent = '';
}

function resetAll() {
    resetUpload();
    resultsSection.classList.add('hidden');
    currentOutputFilename = null;
    
    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

async function performConversion() {
    if (!currentFile) {
        showError('Please select an image first');
        return;
    }
    
    // Show loading spinner
    loadingSpinner.classList.remove('hidden');
    
    try {
        // Create form data
        const formData = new FormData();
        formData.append('image', currentFile);
        formData.append('type', conversionType);
        
        // Send request to backend
        const response = await fetch('/convert', {
            method: 'POST',
            body: formData
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Conversion failed');
        }
        
        const result = await response.json();
        
        if (result.success) {
            displayResults(result);
            showSuccess('Conversion completed successfully!');
        } else {
            throw new Error(result.error || 'Unknown error occurred');
        }
        
    } catch (error) {
        console.error('Conversion error:', error);
        showError('Failed to convert image: ' + error.message);
    } finally {
        loadingSpinner.classList.add('hidden');
    }
}

function displayResults(result) {
    // Hide upload section
    previewSection.classList.add('hidden');
    
    // Display results
    document.getElementById('resultInputImage').src = result.input_image;
    document.getElementById('resultOutputImage').src = result.output_image;
    document.getElementById('conversionInfo').textContent = 
        `${result.conversion_type} • ${result.image_size} • ${new Date(result.timestamp).toLocaleString()}`;
    
    // Set labels
    if (conversionType === 'ct_to_mri') {
        document.getElementById('inputLabel').innerHTML = '<i class="fas fa-x-ray mr-1"></i>CT Scan (Original)';
        document.getElementById('outputLabel').innerHTML = '<i class="fas fa-brain mr-1"></i>MRI Scan (Converted)';
    } else {
        document.getElementById('inputLabel').innerHTML = '<i class="fas fa-brain mr-1"></i>MRI Scan (Original)';
        document.getElementById('outputLabel').innerHTML = '<i class="fas fa-x-ray mr-1"></i>CT Scan (Converted)';
    }
    
    // Show results section
    resultsSection.classList.remove('hidden');
    
    // Store output for download
    window.currentOutputImage = result.output_image;
    currentOutputFilename = result.output_filename;
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function downloadResult() {
    if (!window.currentOutputImage) {
        showError('No image to download');
        return;
    }
    
    // Create download link
    const link = document.createElement('a');
    link.href = window.currentOutputImage;
    
    const conversionLabel = conversionType === 'ct_to_mri' ? 'CT_to_MRI' : 'MRI_to_CT';
    link.download = `converted_${conversionLabel}_${Date.now()}.png`;
    
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    showSuccess('Image downloaded successfully!');
}

async function shareResult() {
    if (!window.currentOutputImage) {
        showError('No image to share');
        return;
    }
    
    try {
        // Convert base64 to blob
        const base64Data = window.currentOutputImage.split(',')[1];
        const byteCharacters = atob(base64Data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type: 'image/png' });
        
        const file = new File([blob], 'converted_image.png', { type: 'image/png' });
        
        // Check if Web Share API is supported
        if (navigator.share) {
            await navigator.share({
                files: [file],
                title: 'Medical Image Conversion',
                text: `${conversionType === 'ct_to_mri' ? 'CT to MRI' : 'MRI to CT'} conversion result`
            });
            showSuccess('Shared successfully!');
        } else {
            // Fallback: copy link
            const url = window.location.href;
            await navigator.clipboard.writeText(url);
            showInfo('Link copied to clipboard! Web Share not supported on this device.');
        }
    } catch (error) {
        console.error('Share error:', error);
        showError('Unable to share. Try downloading instead.');
    }
}

// Toast notifications
function showError(message) {
    showToast(message, 'error');
}

function showSuccess(message) {
    showToast(message, 'success');
}

function showInfo(message) {
    showToast(message, 'info');
}

function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `fixed top-4 right-4 px-6 py-4 rounded-xl shadow-lg z-50 animate-slide-in max-w-sm`;
    
    let bgColor, icon;
    switch(type) {
        case 'error':
            bgColor = 'bg-red-500';
            icon = 'fa-exclamation-circle';
            break;
        case 'success':
            bgColor = 'bg-green-500';
            icon = 'fa-check-circle';
            break;
        default:
            bgColor = 'bg-blue-500';
            icon = 'fa-info-circle';
    }
    
    toast.classList.add(bgColor);
    toast.innerHTML = `
        <div class="flex items-center text-white">
            <i class="fas ${icon} text-xl mr-3"></i>
            <span class="text-sm md:text-base">${message}</span>
        </div>
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(400px)';
        setTimeout(() => toast.remove(), 300);
    }, type === 'error' ? 5000 : 3000);
}

// Prevent page reload on file drop
window.addEventListener('dragover', e => e.preventDefault());
window.addEventListener('drop', e => e.preventDefault());
