document.addEventListener('DOMContentLoaded', () => {
    // Initialize keybinds
    window.keybindSys = new KeybindSystem();
    
    // Core state management
    const state = {
        title: "Lori",
        theme: "default",
        accentHue: 180, // HSL secondary (Ice Cyan)
        primaryHue: 345, // HSL primary (Cyber Crimson)
        
        // combat tab
        flyMode: false,
        auraRange: 15,
        auraKey: "X",
        
        // visuals tab
        espNames: false,
        espBoxes: false,
        espTheme: "laser",
        espColor: "#06b6d4",
        
        // settings tab
        guiKey: "RightControl",
        speedVelocity: 50,
        responsiveDrag: true
    };

    // DOM Elements
    const elements = {
        windowFrame: document.getElementById('roblox-lib-window'),
        titlebar: document.getElementById('window-titlebar'),
        guiTitle: document.getElementById('gui-title'),
        guiCloseBtn: document.getElementById('gui-close-btn'),
        windowContent: document.getElementById('window-content'),
        
        // Tab views
        tabButtons: document.querySelectorAll('.sidebar-tab-btn'),
        tabViews: document.querySelectorAll('.tab-view'),
        
        // combat elements
        btnTriggerAura: document.getElementById('btn-trigger-aura'),
        toggleFlyMode: document.getElementById('toggle-fly-mode'),
        sliderTrackRange: document.getElementById('slider-track-range'),
        sliderFillRange: document.getElementById('slider-fill-range'),
        sliderHandleRange: document.getElementById('slider-handle-range'),
        sliderValRange: document.getElementById('slider-val-range'),
        bindKillAura: document.getElementById('bind-kill-aura'),
        
        // visuals elements
        folderEspHeader: document.getElementById('folder-header-esp'),
        folderEsp: document.getElementById('folder-esp'),
        toggleEspNames: document.getElementById('toggle-esp-names'),
        toggleEspBoxes: document.getElementById('toggle-esp-boxes'),
        dropdownBtnEsp: document.getElementById('dropdown-btn-esp'),
        dropdownValEsp: document.getElementById('dropdown-val-esp'),
        dropdownListEsp: document.getElementById('dropdown-list-esp'),
        dropdownItemsEsp: document.querySelectorAll('#dropdown-list-esp .dropdown-item'),
        cpTriggerEsp: document.getElementById('cp-trigger-esp'),
        cpPanelEsp: document.getElementById('cp-panel-esp'),
        cpSliderEsp: document.getElementById('cp-slider-esp'),
        cpCanvasEsp: document.getElementById('cp-canvas-esp'),
        
        // settings elements
        bindToggleGui: document.getElementById('bind-toggle-gui'),
        sliderTrackSpeed: document.getElementById('slider-track-speed'),
        sliderFillSpeed: document.getElementById('slider-fill-speed'),
        sliderHandleSpeed: document.getElementById('slider-handle-speed'),
        sliderValSpeed: document.getElementById('slider-val-speed'),
        btnGuiUnload: document.getElementById('btn-gui-unload'),
        
        // right config panel
        themeCards: document.querySelectorAll('.theme-card'),
        paletteSwatches: document.getElementById('palette-swatches'),
        btnSaveColor: document.getElementById('btn-save-color'),
        savedPalettesCount: document.getElementById('saved-palettes-count'),
        configWindowTitle: document.getElementById('config-window-title'),
        toggleResponsiveDrag: document.getElementById('toggle-responsive-drag'),
        
        // code panel
        luauCode: document.getElementById('luau-code'),
        copyCodeBtn: document.getElementById('copy-code-btn'),
        toastContainer: document.getElementById('toast-container')
    };

    // Theme values mappings
    const themes = {
        default: { hp: 345, hs: 180 },
        emerald: { hp: 145, hs: 45 },
        sunset: { hp: 345, hs: 25 },
        electric: { hp: 220, hs: 180 }
    };

    /* ==========================================================================
       DRAG-AND-DROP SYSTEM (WITH UNRESTRICTED PAN DRAG BOUNDARIES)
       ========================================================================== */
    let isDragging = false;
    let dragStartX = 0;
    let dragStartY = 0;
    let winStartX = 0;
    let winStartY = 0;

    elements.titlebar.addEventListener('mousedown', (e) => {
        // Only allow left click
        if (e.button !== 0) return;
        
        isDragging = true;
        elements.windowFrame.classList.add('active-glow');
        
        // Capture initial positions
        dragStartX = e.clientX;
        dragStartY = e.clientY;
        
        const rect = elements.windowFrame.getBoundingClientRect();
        const parentRect = document.getElementById('viewport').getBoundingClientRect();
        
        winStartX = rect.left - parentRect.left;
        winStartY = rect.top - parentRect.top;
        
        synth.playClick();
        
        // Apply micro-tilt if responsive dragging is toggled
        if (state.responsiveDrag) {
            elements.windowFrame.style.transition = 'transform 0.1s cubic-bezier(0.25, 0.8, 0.25, 1)';
            elements.windowFrame.style.transform = 'scale(1.01) rotate(0.5deg)';
        }
        
        e.preventDefault();
    });

    window.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        
        const dx = e.clientX - dragStartX;
        const dy = e.clientY - dragStartY;
        
        let newX = winStartX + dx;
        let newY = winStartY + dy;
        
        // UNRESTRICTED DRAGGING: Allow sliding almost fully off the screen boundaries!
        // We only require a tiny 40px square of the titlebar to stay within the viewport bounds.
        const viewport = document.getElementById('viewport');
        const viewWidth = viewport.clientWidth;
        const viewHeight = viewport.clientHeight;
        const winWidth = elements.windowFrame.clientWidth;
        const winHeight = elements.windowFrame.clientHeight;
        
        // Left constraint: let 85% of frame slide off screen
        if (newX < -winWidth + 60) newX = -winWidth + 60;
        // Top constraint: keep titlebar visible so it can always be grabbed
        if (newY < 0) newY = 0;
        // Right constraint: let 85% of frame slide off screen
        if (newX > viewWidth - 60) newX = viewWidth - 60;
        // Bottom constraint: let 85% of frame slide off screen
        if (newY > viewHeight - 40) newY = viewHeight - 40;
        
        elements.windowFrame.style.left = `${newX}px`;
        elements.windowFrame.style.top = `${newY}px`;
    });

    window.addEventListener('mouseup', () => {
        if (!isDragging) return;
        isDragging = false;
        
        elements.windowFrame.classList.remove('active-glow');
        
        // Remove micro-tilt
        if (state.responsiveDrag) {
            elements.windowFrame.style.transform = 'scale(1) rotate(0deg)';
            elements.windowFrame.style.transition = '';
        }
    });

    // Close button mock
    elements.guiCloseBtn.addEventListener('click', () => {
        elements.windowFrame.style.display = 'none';
        synth.playToggle(false);
        showToast("GUI Window Closed (Press " + state.guiKey + " to Show)", "fa-eye-slash");
    });

    /* ==========================================================================
       TAB SYSTEM
       ========================================================================== */
    elements.tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const targetTab = btn.dataset.tab;
            
            // Toggle active buttons
            elements.tabButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            // Toggle views
            elements.tabViews.forEach(v => {
                v.classList.remove('active');
                if (v.id === `tab-${targetTab}`) {
                    v.classList.add('active');
                }
            });
            
            synth.playClick();
        });
    });

    /* ==========================================================================
       FOLDER SECTIONS (COLLAPSIBLE)
       ========================================================================== */
    elements.folderEspHeader.addEventListener('click', () => {
        elements.folderEsp.classList.toggle('collapsed');
        synth.playClick();
    });

    /* ==========================================================================
       IOS TOGGLES SYSTEM
       ========================================================================== */
    function initToggle(elem, callback) {
        elem.addEventListener('click', () => {
            const row = elem.closest('.widget-row') || elem.parentElement;
            const isActive = row.classList.toggle('active-toggle');
            
            synth.playToggle(isActive);
            callback(isActive);
            window.updateLuauCode();
        });
    }

    initToggle(elements.toggleFlyMode, (isActive) => {
        state.flyMode = isActive;
        showToast(isActive ? "Super Fly Mode Activated" : "Fly Mode Deactivated", "fa-plane-departure");
    });

    initToggle(elements.toggleEspNames, (isActive) => {
        state.espNames = isActive;
        showToast(isActive ? "Enabled ESP Overlays" : "Disabled ESP Overlays", "fa-user-tag");
    });

    initToggle(elements.toggleEspBoxes, (isActive) => {
        state.espBoxes = isActive;
        showToast(isActive ? "Enabled Bounding Outlines" : "Disabled Bounding Outlines", "fa-vector-square");
    });

    initToggle(elements.toggleResponsiveDrag, (isActive) => {
        state.responsiveDrag = isActive;
        showToast(isActive ? "Responsive Tilt Active" : "Responsive Tilt Disabled", "fa-compass");
    });

    /* ==========================================================================
       SLIDERS (TWIST) SYSTEM WITH WAVE SWEEP SYNTH HUMS
       ========================================================================== */
    function setupSlider(track, fill, handle, valElem, min, max, initial, callback) {
        let isSliding = false;
        
        function updateVal(clientX) {
            const rect = track.getBoundingClientRect();
            let pct = (clientX - rect.left) / rect.width;
            if (pct < 0) pct = 0;
            if (pct > 1) pct = 1;
            
            fill.style.width = `${pct * 100}%`;
            handle.style.left = `calc(${pct * 100}% - 3px)`;
            
            const rawVal = min + (pct * (max - min));
            const roundedVal = Math.round(rawVal);
            
            valElem.textContent = roundedVal;
            callback(roundedVal);
            
            // Audio sweep feedback
            synth.updateSliderSweep(pct * 100);
        }

        handle.addEventListener('mousedown', (e) => {
            if (e.button !== 0) return;
            isSliding = true;
            synth.startSliderSweep();
            e.preventDefault();
            e.stopPropagation();
        });

        track.addEventListener('mousedown', (e) => {
            if (e.button !== 0) return;
            isSliding = true;
            synth.startSliderSweep();
            updateVal(e.clientX);
            e.preventDefault();
        });

        window.addEventListener('mousemove', (e) => {
            if (!isSliding) return;
            updateVal(e.clientX);
        });

        window.addEventListener('mouseup', () => {
            if (!isSliding) return;
            isSliding = false;
            synth.stopSliderSweep();
            synth.playTick(440, 0.05);
            window.updateLuauCode();
        });

        // Set initial
        const initPct = (initial - min) / (max - min);
        fill.style.width = `${initPct * 100}%`;
        handle.style.left = `calc(${initPct * 100}% - 3px)`;
        valElem.textContent = initial;
    }

    setupSlider(
        elements.sliderTrackRange,
        elements.sliderFillRange,
        elements.sliderHandleRange,
        elements.sliderValRange,
        5, 50, 15,
        (val) => {
            state.auraRange = val;
        }
    );

    setupSlider(
        elements.sliderTrackSpeed,
        elements.sliderFillSpeed,
        elements.sliderHandleSpeed,
        elements.sliderValSpeed,
        16, 200, 50,
        (val) => {
            state.speedVelocity = val;
        }
    );

    /* ==========================================================================
       DROPDOWNS SYSTEM
       ========================================================================== */
    elements.dropdownBtnEsp.addEventListener('click', (e) => {
        e.stopPropagation();
        elements.dropdownListEsp.classList.toggle('open');
        synth.playClick();
    });

    elements.dropdownItemsEsp.forEach(item => {
        item.addEventListener('click', () => {
            const val = item.dataset.val;
            const text = item.textContent;
            
            elements.dropdownValEsp.textContent = text;
            state.espTheme = val;
            
            elements.dropdownItemsEsp.forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            
            synth.playClick();
            showToast(`ESP Theme Set: ${text}`, "fa-paint-roller");
            window.updateLuauCode();
        });
    });

    window.addEventListener('click', () => {
        elements.dropdownListEsp.classList.remove('open');
        elements.cpPanelEsp.classList.remove('open');
    });

    /* ==========================================================================
       COLOR PICKER CORE (CANVAS + SLIDER SYSTEM)
       ========================================================================== */
    elements.cpTriggerEsp.addEventListener('click', (e) => {
        e.stopPropagation();
        // Toggle panel open
        const isOpen = elements.cpPanelEsp.classList.toggle('open');
        synth.playClick();
        if (isOpen) {
            drawColorCanvas(state.accentHue);
        }
    });

    elements.cpPanelEsp.addEventListener('click', (e) => {
        e.stopPropagation(); // Avoid closing panel
    });

    // Slider controls Hue
    elements.cpSliderEsp.addEventListener('input', (e) => {
        const hue = e.target.value;
        state.accentHue = hue;
        drawColorCanvas(hue);
        updateColorFromPicker(hue, 1, 0.5); // Default to full bright/sat first
    });

    function drawColorCanvas(hue) {
        const canvas = elements.cpCanvasEsp;
        // Check if element has dimensions
        if (canvas.clientWidth === 0) return;
    }

    // Canvas click selection
    elements.cpCanvasEsp.addEventListener('mousedown', (e) => {
        const rect = elements.cpCanvasEsp.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        
        // Simulate picking Saturation (x) and Lightness (y)
        const sat = Math.round((x / rect.width) * 100);
        const light = Math.round(100 - (y / rect.height) * 50); // Map to upper 50% - 100%
        
        updateColorFromPicker(state.accentHue, sat / 100, light / 100);
        
        synth.playTick(600, 0.04);
    });

    function updateColorFromPicker(h, s, l) {
        // convert HSL to Hex
        const hex = hslToHex(h, s * 100, l * 100);
        state.espColor = hex;
        elements.cpTriggerEsp.style.backgroundColor = hex;
        
        // Update live CSS variable for mockup visual accents
        document.documentElement.style.setProperty('--color-secondary', `hsl(${h}, ${s*100}%, ${l*100}%)`);
        document.documentElement.style.setProperty('--color-secondary-glow', `hsla(${h}, ${s*100}%, ${l*100}%, 0.3)`);
        
        // Highlight outline borders inside viewport if ESP box is on
        const folder = document.getElementById('folder-esp');
        if (folder) {
            folder.style.borderColor = hex;
        }
    }

    // Helper HSL to Hex Converter
    function hslToHex(h, s, l) {
        l /= 100;
        const a = s * Math.min(l, 1 - l) / 100;
        const f = n => {
            const k = (n + h / 30) % 12;
            const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
            return Math.round(255 * color).toString(16).padStart(2, '0');
        };
        return `#${f(0)}${f(8)}${f(4)}`;
    }

    /* ==========================================================================
       RIGHT PANEL CONFIG: PRESETS & ACCENTS
       ========================================================================== */
    // Theme Card Selection
    elements.themeCards.forEach(card => {
        card.addEventListener('click', () => {
            const theme = card.dataset.theme;
            const hp = card.dataset.hp;
            const hs = card.dataset.hs;
            
            elements.themeCards.forEach(c => c.classList.remove('active'));
            card.classList.add('active');
            
            state.theme = theme;
            state.primaryHue = hp;
            state.accentHue = hs;
            
            // Dynamically alter browser visual roots
            document.documentElement.style.setProperty('--hue-primary', hp);
            document.documentElement.style.setProperty('--hue-secondary', hs);
            
            // Sync picker slider
            elements.cpSliderEsp.value = hs;
            const hexColor = hslToHex(hs, 100, 55);
            state.espColor = hexColor;
            elements.cpTriggerEsp.style.backgroundColor = hexColor;
            
            // Sync mock elements colors
            const icon = document.getElementById('titlebar-icon');
            if (icon) icon.style.color = `hsl(${hp}, 100%, 60%)`;
            
            synth.playMenuNotification();
            showToast(`Applied Theme: ${card.querySelector('.theme-name').textContent}`, "fa-palette");
            window.updateLuauCode();
        });
    });

    // Custom swatches additions
    let customColors = ["#06b6d4", "#a855f7", "#10b981", "#f59e0b", "#ec4899"];
    
    function refreshSwatches() {
        elements.paletteSwatches.innerHTML = '';
        customColors.forEach(color => {
            const swatch = document.createElement('span');
            swatch.className = 'palette-swatch';
            if (state.espColor.toLowerCase() === color.toLowerCase()) {
                swatch.classList.add('active');
            }
            swatch.style.backgroundColor = color;
            swatch.dataset.color = color;
            
            swatch.addEventListener('click', () => {
                // Apply color
                state.espColor = color;
                elements.cpTriggerEsp.style.backgroundColor = color;
                
                // Parse HSL from color hex
                const hsl = hexToHSL(color);
                state.accentHue = hsl.h;
                
                document.documentElement.style.setProperty('--hue-secondary', hsl.h);
                document.documentElement.style.setProperty('--color-secondary', `hsl(${hsl.h}, ${hsl.s}%, ${hsl.l}%)`);
                document.documentElement.style.setProperty('--color-secondary-glow', `hsla(${hsl.h}, ${hsl.s}%, ${hsl.l}%, 0.3)`);
                
                // Set active swatch class
                document.querySelectorAll('.palette-swatch').forEach(s => s.classList.remove('active'));
                swatch.classList.add('active');
                
                synth.playClick();
                showToast(`Swapped Color Accent`, "fa-paint-brush");
                window.updateLuauCode();
            });
            
            elements.paletteSwatches.appendChild(swatch);
        });
        
        elements.savedPalettesCount.textContent = `${customColors.length} custom presets loaded`;
    }

    elements.btnSaveColor.addEventListener('click', () => {
        const color = state.espColor;
        if (!customColors.includes(color)) {
            customColors.push(color);
            refreshSwatches();
            synth.playMenuNotification();
            showToast("Added Color to Presets List", "fa-plus-circle");
        } else {
            showToast("Color already exists in Swatches", "fa-info-circle");
        }
    });

    function hexToHSL(hex) {
        let r = parseInt(hex.substring(1,3), 16) / 255;
        let g = parseInt(hex.substring(3,5), 16) / 255;
        let b = parseInt(hex.substring(5,7), 16) / 255;
        let max = Math.max(r, g, b), min = Math.min(r, g, b);
        let h, s, l = (max + min) / 2;
        if (max === min) {
            h = s = 0; // achromatic
        } else {
            let d = max - min;
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
                case r: h = (g - b) / d + (g < b ? 6 : 0); break;
                case g: h = (b - r) / d + 2; break;
                case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }
        return { h: Math.round(h * 360), s: Math.round(s * 100), l: Math.round(l * 100) };
    }

    // Hook Window Title input config
    elements.configWindowTitle.addEventListener('input', (e) => {
        const val = e.target.value || "Lori";
        elements.guiTitle.textContent = val;
        state.title = val;
        window.updateLuauCode();
    });

    // Unload GUI Button trigger
    elements.btnGuiUnload.addEventListener('click', () => {
        elements.windowFrame.classList.add('toast-fade-out');
        synth.playToggle(false);
        setTimeout(() => {
            elements.windowFrame.style.display = 'none';
            elements.windowFrame.classList.remove('toast-fade-out');
        }, 300);
        showToast("Exited and Cleaned Roblox Hub UI", "fa-power-off");
    });

    /* ==========================================================================
       RIGHT PANEL MAIN NAVIGATION TABS
       ========================================================================== */
    window.switchRightPanel = function(panel) {
        document.getElementById('tab-btn-config').classList.remove('active');
        document.getElementById('tab-btn-source').classList.remove('active');
        document.getElementById('panel-config').style.display = 'none';
        document.getElementById('panel-source').style.display = 'none';
        
        if (panel === 'config') {
            document.getElementById('tab-btn-config').classList.add('active');
            document.getElementById('panel-config').style.display = 'flex';
        } else {
            document.getElementById('tab-btn-source').classList.add('active');
            document.getElementById('panel-source').style.display = 'flex';
            window.updateLuauCode();
        }
        synth.playClick();
    };

    /* ==========================================================================
       LUA CODE COMPILATION ENGINE
       ========================================================================== */
    window.updateLuauCode = function() {
        // Grab values dynamically from keybind widgets
        const activeAuraKey = document.getElementById('bind-kill-aura').textContent;
        const activeGuiKey = document.getElementById('bind-toggle-gui').textContent;
        
        state.auraKey = activeAuraKey;
        state.guiKey = activeGuiKey;

        const codeStr = `-- [ Lori Roblox GUI Library Code Configuration ]
-- Paste this script into your Roblox Studio LocalScript or Exploit Executor

local <span class="keyword">LoriLib</span> = loadstring(game:HttpGet(<span class="string">"https://raw.githubusercontent.com/Fij832/roblox-ui-library/main/AntigravityLib.lua?nocache="</span> .. tostring(os.time())))()

local <span class="keyword">Window</span> = <span class="keyword">LoriLib</span>:<span class="method">CreateWindow</span><span class="bracket">{</span>
    Name = <span class="string">"${state.title}"</span>,
    ThemeAccent = Color3.fromHex(<span class="string">"${state.espColor}"</span>),
    DefaultToggleKey = Enum.KeyCode.${state.guiKey},
    ResponsiveTilt = ${state.responsiveDrag}
<span class="bracket">}</span>

local <span class="keyword">CombatTab</span> = <span class="keyword">Window</span>:<span class="method">CreateTab</span>(<span class="string">"Combat"</span>)
local <span class="keyword">VisualsTab</span> = <span class="keyword">Window</span>:<span class="method">CreateTab</span>(<span class="string">"Visuals"</span>)
local <span class="keyword">SettingsTab</span> = <span class="keyword">Window</span>:<span class="method">CreateTab</span>(<span class="string">"Settings"</span>)

<span class="comment">-- 1. Combat Actions</span>
local <span class="keyword">CombatFolder</span> = <span class="keyword">CombatTab</span>:<span class="method">CreateFolder</span>(<span class="string">"Assault Features"</span>)

<span class="keyword">CombatFolder</span>:<span class="method">CreateButton</span><span class="bracket">{</span>
    Name = <span class="string">"Instant Kill Aura"</span>,
    Description = <span class="string">"Automatically target and attack nearby hostile targets"</span>,
    InteractText = <span class="string">"Strike"</span>,
    Callback = <span class="keyword">function</span>()
        print(<span class="string">"Strike triggered via Kill Aura!"</span>)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">CombatFolder</span>:<span class="method">CreateToggle</span><span class="bracket">{</span>
    Name = <span class="string">"Super Fly Mode"</span>,
    Description = <span class="string">"Bypass default physics controls and hover through terrain"</span>,
    Default = ${state.flyMode},
    Callback = <span class="keyword">function</span>(state)
        print(<span class="string">"Fly Mode toggled: "</span>, state)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">CombatFolder</span>:<span class="method">CreateSlider</span><span class="bracket">{</span>
    Name = <span class="string">"Aura Strike Distance"</span>,
    Description = <span class="string">"Adjust the radial range for aura targeting (studs)"</span>,
    Min = 5,
    Max = 50,
    Default = ${state.auraRange},
    Callback = <span class="keyword">function</span>(studs)
        print(<span class="string">"Range set to "</span>, studs, <span class="string">" studs"</span>)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">CombatFolder</span>:<span class="method">CreateKeybind</span><span class="bracket">{</span>
    Name = <span class="string">"Aura Activation Bind"</span>,
    Description = <span class="string">"Bind a keyboard trigger to quickly fire strike events"</span>,
    Default = Enum.KeyCode.${state.auraKey},
    Callback = <span class="keyword">function</span>()
        print(<span class="string">"Aura custom trigger binding event fired!"</span>)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="comment">-- 2. Visual ESP Folder Customization</span>
local <span class="keyword">EspFolder</span> = <span class="keyword">VisualsTab</span>:<span class="method">CreateFolder</span>(<span class="string">"ESP Customizer Options"</span>)

<span class="keyword">EspFolder</span>:<span class="method">CreateToggle</span><span class="bracket">{</span>
    Name = <span class="string">"Name Overlays"</span>,
    Description = <span class="string">"Draw username tags above target capsules"</span>,
    Default = ${state.espNames},
    Callback = <span class="keyword">function</span>(state)
        print(<span class="string">"Draw Names toggled: "</span>, state)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">EspFolder</span>:<span class="method">CreateToggle</span><span class="bracket">{</span>
    Name = <span class="string">"Bounding Boxes"</span>,
    Description = <span class="string">"Draw animated border outlines around hitboxes"</span>,
    Default = ${state.espBoxes},
    Callback = <span class="keyword">function</span>(state)
        print(<span class="string">"Draw Boxes toggled: "</span>, state)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">EspFolder</span>:<span class="method">CreateDropdown</span><span class="bracket">{</span>
    Name = <span class="string">"Bounding Outline Theme"</span>,
    Description = <span class="string">"Choose a gorgeous preset neon outline effect"</span>,
    Options = <span class="bracket">{</span><span class="string">"Glitch Laser"</span>, <span class="string">"Smooth Neon"</span>, <span class="string">"Minimal Box"</span><span class="bracket">}</span>,
    Default = <span class="string">"${state.espTheme === 'laser' ? 'Glitch Laser' : state.espTheme === 'neon' ? 'Smooth Neon' : 'Minimal Box'}"</span>,
    Callback = <span class="keyword">function</span>(selected)
        print(<span class="string">"ESP Outline selected: "</span>, selected)
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="comment">-- 3. Settings Configurations</span>
local <span class="keyword">ConfigFolder</span> = <span class="keyword">SettingsTab</span>:<span class="method">CreateFolder</span>(<span class="string">"Interface Settings"</span>)

<span class="keyword">ConfigFolder</span>:<span class="method">CreateSlider</span><span class="bracket">{</span>
    Name = <span class="string">"Speed Hack Velocity"</span>,
    Description = <span class="string">"Walk speed multiplier for speed hack"</span>,
    Min = 16,
    Max = 200,
    Default = ${state.speedVelocity},
    Callback = <span class="keyword">function</span>(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    <span class="keyword">end</span>
<span class="bracket">}</span>

<span class="keyword">ConfigFolder</span>:<span class="method">CreateButton</span><span class="bracket">{</span>
    Name = <span class="string">"Safely Exit Overlay"</span>,
    Description = <span class="string">"Safely close the overlay and restore settings"</span>,
    InteractText = <span class="string">"Exit"</span>,
    Callback = <span class="keyword">function</span>()
        <span class="keyword">Window</span>:<span class="method">Destroy</span>()
    <span class="keyword">end</span>
<span class="bracket">}</span>
`;
        
        elements.luauCode.innerHTML = codeStr;
    };

    // Copy to clipboard support
    elements.copyCodeBtn.addEventListener('click', () => {
        const textToCopy = elements.luauCode.textContent;
        navigator.clipboard.writeText(textToCopy).then(() => {
            synth.playMenuNotification();
            showToast("Copied script configuration successfully!", "fa-circle-check");
        }).catch(err => {
            console.error('Copy failed: ', err);
            showToast("Failed to copy code, copy manually", "fa-circle-exclamation");
        });
    });

    window.copyLuauScript = function() {
        const fullLibText = `-- [ Lori Roblox GUI Library - Complete Script ]
-- Visit the dashboard builder online to customize themes and presets!
`;
        navigator.clipboard.writeText(fullLibText);
        synth.playMenuNotification();
        showToast("Copied core library script to clipboard!", "fa-floppy-disk");
    };

    /* ==========================================================================
       TOAST ALERTS SYSTEM
       ========================================================================== */
    window.showToast = function(message, iconName = "fa-bell") {
        const toast = document.createElement('div');
        toast.className = 'toast';
        if (iconName.includes("keyboard") || iconName.includes("circle-check") || iconName.includes("floppy")) {
            toast.classList.add('toast-primary');
        }
        
        toast.innerHTML = `
            <i class="fa-solid ${iconName} toast-icon"></i>
            <span class="toast-text">${message}</span>
        `;
        
        elements.toastContainer.appendChild(toast);
        
        // Auto remove toast
        setTimeout(() => {
            toast.classList.add('toast-fade-out');
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, 2800);
    };

    // Initial code compile
    window.updateLuauCode();
    refreshSwatches();
    
    // Welcome Notification
    setTimeout(() => {
        showToast("Lori Hub Loaded Successfully", "fa-shield-halved");
        synth.playMenuNotification();
    }, 800);
});
