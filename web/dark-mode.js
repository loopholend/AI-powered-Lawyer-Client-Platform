// Dark Mode Toggle Functionality
function toggleDarkMode() {
    document.body.classList.toggle('dark-mode');
    
    var isDark = document.body.classList.contains('dark-mode');
    localStorage.setItem('darkMode', isDark);
    
    var icon = document.getElementById('theme-icon');
    if (icon) {
        if (isDark) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
        } else {
            icon.classList.remove('fa-sun');
            icon.classList.add('fa-moon');
        }
    }
    
    // Apply to iframe if exists
    var iframe = document.getElementById('contentFrame');
    if (iframe && iframe.contentDocument) {
        try {
            iframe.contentDocument.body.classList.toggle('dark-mode', isDark);
        } catch (e) {
            console.log('Cannot access iframe content');
        }
    }
}

// Load dark mode preference on page load
window.addEventListener('DOMContentLoaded', function() {
    var darkMode = localStorage.getItem('darkMode');
    if (darkMode === 'true') {
        document.body.classList.add('dark-mode');
        
        var icon = document.getElementById('theme-icon');
        if (icon) {
            icon.classList.remove('fa-moon');
            icon.classList.add('fa-sun');
        }
    }
});

// Apply dark mode to iframe when it loads
window.addEventListener('load', function() {
    var iframe = document.getElementById('contentFrame');
    if (iframe) {
        iframe.addEventListener('load', function() {
            var darkMode = localStorage.getItem('darkMode');
            if (darkMode === 'true' && iframe.contentDocument) {
                try {
                    iframe.contentDocument.body.classList.add('dark-mode');
                } catch (e) {
                    console.log('Cannot access iframe content');
                }
            }
        });
        
        // Also apply immediately if iframe is already loaded
        var darkMode = localStorage.getItem('darkMode');
        if (darkMode === 'true' && iframe.contentDocument) {
            try {
                iframe.contentDocument.body.classList.add('dark-mode');
            } catch (e) {
                console.log('Cannot access iframe content');
            }
        }
    }
});

// Export function for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { toggleDarkMode };
}
