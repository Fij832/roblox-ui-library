class WebAudioSynth {
    constructor() {
        this.ctx = null;
        this.sliderOsc = null;
        this.sliderGain = null;
    }

    init() {
        if (!this.ctx) {
            this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    playClick() {
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(800, now);
        osc.frequency.exponentialRampToValueAtTime(1500, now + 0.05);

        gain.gain.setValueAtTime(0.12, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.06);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.06);
    }

    playToggle(state) {
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'triangle';
        if (state) {
            osc.frequency.setValueAtTime(250, now);
            osc.frequency.exponentialRampToValueAtTime(600, now + 0.15);
        } else {
            osc.frequency.setValueAtTime(450, now);
            osc.frequency.exponentialRampToValueAtTime(150, now + 0.18);
        }

        gain.gain.setValueAtTime(0.1, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.2);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.2);
    }

    playTick(freq = 600, duration = 0.04) {
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, now);

        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + duration);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + duration);
    }

    startSliderSweep() {
        this.init();
        if (!this.ctx) return;

        if (this.sliderOsc) return;

        const now = this.ctx.currentTime;
        this.sliderOsc = this.ctx.createOscillator();
        this.sliderGain = this.ctx.createGain();

        this.sliderOsc.type = 'triangle';
        this.sliderOsc.frequency.setValueAtTime(200, now);

        this.sliderGain.gain.setValueAtTime(0, now);
        this.sliderGain.gain.linearRampToValueAtTime(0.04, now + 0.05);

        // Add filter to soften the sweep
        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(600, now);

        this.sliderOsc.connect(filter);
        filter.connect(this.sliderGain);
        this.sliderGain.connect(this.ctx.destination);

        this.sliderOsc.start(now);
    }

    updateSliderSweep(value) {
        if (!this.sliderOsc || !this.ctx) return;
        const now = this.ctx.currentTime;
        // Map 0-100 value to frequency range 200-800Hz
        const freq = 200 + (value * 6);
        this.sliderOsc.frequency.setTargetAtTime(freq, now, 0.02);
    }

    stopSliderSweep() {
        if (!this.sliderOsc || !this.sliderGain || !this.ctx) return;
        const now = this.ctx.currentTime;
        this.sliderGain.gain.cancelScheduledValues(now);
        this.sliderGain.gain.setValueAtTime(this.sliderGain.gain.value, now);
        this.sliderGain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
        
        const osc = this.sliderOsc;
        setTimeout(() => {
            try {
                osc.stop();
            } catch (e) {}
        }, 120);

        this.sliderOsc = null;
        this.sliderGain = null;
    }

    playMenuNotification() {
        this.init();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const notes = [440, 554, 659, 880]; // A major chord arpeggio
        notes.forEach((freq, idx) => {
            const time = now + (idx * 0.07);
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();

            osc.type = 'sine';
            osc.frequency.setValueAtTime(freq, time);

            gain.gain.setValueAtTime(0.06, time);
            gain.gain.exponentialRampToValueAtTime(0.001, time + 0.15);

            osc.connect(gain);
            gain.connect(this.ctx.destination);

            osc.start(time);
            osc.stop(time + 0.15);
        });
    }
}

// Global instance
const synth = new WebAudioSynth();
window.synth = synth;
// Resume AudioContext on initial interaction
window.addEventListener('click', () => synth.init(), { once: true });
window.addEventListener('keydown', () => synth.init(), { once: true });
