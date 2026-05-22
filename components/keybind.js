class KeybindSystem {
    constructor() {
        this.bindElements = document.querySelectorAll('.keybind-widget');
        this.activeElement = null;
        this.listeners = {};
        
        this.init();
    }

    init() {
        this.bindElements.forEach(elem => {
            // Set initial state from default data attribute
            const defKey = elem.dataset.default || 'F';
            elem.textContent = defKey;
            elem.dataset.key = defKey;
            
            elem.addEventListener('click', (e) => {
                e.stopPropagation();
                this.startListening(elem);
            });
        });

        // Keydown listener for binding and trigger actions
        window.addEventListener('keydown', this.handleKeyDown.bind(this));
    }

    startListening(element) {
        if (this.activeElement) {
            this.activeElement.classList.remove('listening');
            this.activeElement.textContent = this.activeElement.dataset.key;
        }
        
        this.activeElement = element;
        element.classList.add('listening');
        element.textContent = 'Listening...';
        
        if (window.synth && typeof window.synth.playClick === 'function') {
            window.synth.playClick();
        }
    }

    handleKeyDown(e) {
        // 1. If currently binding a key
        if (this.activeElement) {
            e.preventDefault();
            e.stopPropagation();
            
            let keyName = this.normalizeKey(e.key, e.code);
            
            // Avoid binding to Escape to cancel
            if (keyName === 'Escape') {
                this.activeElement.classList.remove('listening');
                this.activeElement.textContent = this.activeElement.dataset.key;
                this.activeElement = null;
                if (window.synth && typeof window.synth.playToggle === 'function') {
                    window.synth.playToggle(false);
                }
                return;
            }

            this.activeElement.dataset.key = keyName;
            this.activeElement.textContent = keyName;
            this.activeElement.classList.remove('listening');
            
            if (window.synth && typeof window.synth.playToggle === 'function') {
                window.synth.playToggle(true);
            }
            if (window.showToast) {
                window.showToast(`Bound action to Key: ${keyName}`, "fa-keyboard");
            }
            
            // Trigger code compilation
            if (window.updateLuauCode) {
                window.updateLuauCode();
            }
            
            this.activeElement = null;
            return;
        }

        // 2. Otherwise, check if user pressed a bound key globally
        // Disable triggers if user is typing in a text field
        if (document.activeElement) {
            const activeTag = document.activeElement.tagName.toLowerCase();
            if (activeTag === 'textarea' || activeTag === 'input') {
                return;
            }
        }

        const pressedKey = this.normalizeKey(e.key, e.code);
        this.bindElements.forEach(elem => {
            const boundKey = elem.dataset.key;
            if (boundKey && pressedKey.toLowerCase() === boundKey.toLowerCase()) {
                e.preventDefault();
                this.triggerKeybindAction(elem.id, boundKey);
            }
        });
    }

    normalizeKey(key, code) {
        // Map standard JS key names to Roblox Enum.KeyCode names
        if (key === ' ') return 'Space';
        if (key === 'Control') {
            return code === 'ControlRight' ? 'RightControl' : 'LeftControl';
        }
        if (key === 'Shift') {
            return code === 'ShiftRight' ? 'RightShift' : 'LeftShift';
        }
        if (key === 'Alt') {
            return code === 'AltRight' ? 'RightAlt' : 'LeftAlt';
        }
        if (key === 'Meta') return 'LeftSuper';
        
        // Single letters
        if (key.length === 1 && key >= 'a' && key <= 'z') {
            return key.toUpperCase();
        }
        
        // Return normalized arrows
        if (key === 'ArrowUp') return 'Up';
        if (key === 'ArrowDown') return 'Down';
        if (key === 'ArrowLeft') return 'Left';
        if (key === 'ArrowRight') return 'Right';
        
        // Clean double names or defaults
        return key;
    }

    triggerKeybindAction(elemId, key) {
        let actionName = "Custom Action";
        let icon = "fa-bolt";
        
        if (elemId === 'bind-toggle-gui') {
            actionName = "Toggle Menu Visibility";
            icon = "fa-eye-slash";
            
            const win = document.getElementById('roblox-lib-window');
            if (win) {
                if (win.style.display === 'none') {
                    win.style.display = 'flex';
                    win.style.animation = 'tabSpawn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.1) forwards';
                    if (window.synth && typeof window.synth.playToggle === 'function') {
                        window.synth.playToggle(true);
                    }
                } else {
                    win.style.display = 'none';
                    if (window.synth && typeof window.synth.playToggle === 'function') {
                        window.synth.playToggle(false);
                    }
                }
            }
        } else if (elemId === 'bind-kill-aura') {
            actionName = "Instant Kill Aura";
            icon = "fa-skull";
            
            // Highlight row-kill-aura brief strike neon effect
            const auraRow = document.getElementById('row-kill-aura');
            if (auraRow) {
                auraRow.style.borderColor = 'var(--color-primary)';
                auraRow.style.boxShadow = '0 0 10px var(--color-primary-glow)';
                setTimeout(() => {
                    auraRow.style.borderColor = '';
                    auraRow.style.boxShadow = '';
                }, 300);
            }

            if (window.synth && typeof window.synth.playTick === 'function') {
                window.synth.playTick(180, 0.15);
                setTimeout(() => window.synth.playTick(360, 0.1), 100);
            }
        }

        if (window.showToast) {
            window.showToast(`⚡ Bind Triggered [${key}]: ${actionName}`, icon);
        }
    }
}

// Global hook
window.KeybindSystem = KeybindSystem;
