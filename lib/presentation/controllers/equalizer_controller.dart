import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_preferences_controller.dart';

/// Equalizer state containing current settings and presets
class EqualizerState {
  const EqualizerState({
    this.isEnabled = false,
    this.currentPreset = 'normal',
    this.customValues = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    this.bassBoost = 0.0,
    this.virtualizer = 0.0,
    this.loudnessEnhancer = 0.0,
    this.preAmp = 0.0,
    this.isLoading = false,
    this.error,
  });

  final bool isEnabled;
  final String currentPreset;
  final List<double> customValues; // 10-band EQ values (-20.0 to +20.0 dB)
  final double bassBoost; // 0.0 to 1.0
  final double virtualizer; // 0.0 to 1.0
  final double loudnessEnhancer; // 0.0 to 1.0
  final double preAmp; // -20.0 to +20.0 dB
  final bool isLoading;
  final String? error;

  EqualizerState copyWith({
    bool? isEnabled,
    String? currentPreset,
    List<double>? customValues,
    double? bassBoost,
    double? virtualizer,
    double? loudnessEnhancer,
    double? preAmp,
    bool? isLoading,
    String? error,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      currentPreset: currentPreset ?? this.currentPreset,
      customValues: customValues ?? this.customValues,
      bassBoost: bassBoost ?? this.bassBoost,
      virtualizer: virtualizer ?? this.virtualizer,
      loudnessEnhancer: loudnessEnhancer ?? this.loudnessEnhancer,
      preAmp: preAmp ?? this.preAmp,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Equalizer controller managing audio effects and settings
/// Provides 10-band equalizer with presets and custom settings
class EqualizerController extends StateNotifier<EqualizerState> {
  final Ref _ref;

  EqualizerController(this._ref) : super(const EqualizerState()) {
    _initializeFromPreferences();
  }

  /// Initialize equalizer from user preferences
  void _initializeFromPreferences() {
    final preferences = _ref.read(userPreferencesControllerProvider);
    
    state = state.copyWith(
      isEnabled: preferences.equalizerEnabled,
      currentPreset: preferences.equalizerPreset,
      customValues: preferences.customEqualizerValues ?? state.customValues,
    );
  }

  /// Toggle equalizer on/off
  Future<void> toggleEqualizer() async {
    final newEnabled = !state.isEnabled;
    state = state.copyWith(isEnabled: newEnabled);
    
    // Update preferences
    await _ref.read(userPreferencesControllerProvider.notifier)
        .updateEqualizerSettings(enabled: newEnabled);
    
    // Apply to audio system
    await _applyEqualizerSettings();
  }

  /// Set equalizer preset
  Future<void> setPreset(String presetName) async {
    final presets = _ref.read(userPreferencesControllerProvider.notifier)
        .getEqualizerPresets();
    
    final preset = presets.firstWhere(
      (p) => p.name == presetName,
      orElse: () => presets.first,
    );

    state = state.copyWith(
      currentPreset: presetName,
      customValues: _expandValues(preset.values),
    );

    // Update preferences
    await _ref.read(userPreferencesControllerProvider.notifier)
        .updateEqualizerSettings(
          preset: presetName,
          customValues: state.customValues,
        );

    // Apply to audio system
    await _applyEqualizerSettings();
  }

  /// Update custom equalizer band value
  Future<void> updateBand(int bandIndex, double value) async {
    if (bandIndex < 0 || bandIndex >= state.customValues.length) return;
    
    final newValues = List<double>.from(state.customValues);
    newValues[bandIndex] = value.clamp(-20.0, 20.0);
    
    state = state.copyWith(
      currentPreset: 'custom',
      customValues: newValues,
    );

    // Update preferences
    await _ref.read(userPreferencesControllerProvider.notifier)
        .updateEqualizerSettings(
          preset: 'custom',
          customValues: newValues,
        );

    // Apply to audio system
    await _applyEqualizerSettings();
  }

  /// Set bass boost level
  Future<void> setBassBoost(double level) async {
    final clampedLevel = level.clamp(0.0, 1.0);
    state = state.copyWith(bassBoost: clampedLevel);
    await _applyAudioEffects();
  }

  /// Set virtualizer level
  Future<void> setVirtualizer(double level) async {
    final clampedLevel = level.clamp(0.0, 1.0);
    state = state.copyWith(virtualizer: clampedLevel);
    await _applyAudioEffects();
  }

  /// Set loudness enhancer level
  Future<void> setLoudnessEnhancer(double level) async {
    final clampedLevel = level.clamp(0.0, 1.0);
    state = state.copyWith(loudnessEnhancer: clampedLevel);
    await _applyAudioEffects();
  }

  /// Set pre-amplifier level
  Future<void> setPreAmp(double level) async {
    final clampedLevel = level.clamp(-20.0, 20.0);
    state = state.copyWith(preAmp: clampedLevel);
    await _applyEqualizerSettings();
  }

  /// Reset equalizer to flat
  Future<void> resetToFlat() async {
    const flatValues = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    
    state = state.copyWith(
      currentPreset: 'normal',
      customValues: flatValues,
      bassBoost: 0.0,
      virtualizer: 0.0,
      loudnessEnhancer: 0.0,
      preAmp: 0.0,
    );

    // Update preferences
    await _ref.read(userPreferencesControllerProvider.notifier)
        .updateEqualizerSettings(
          preset: 'normal',
          customValues: flatValues,
        );

    // Apply to audio system
    await _applyEqualizerSettings();
    await _applyAudioEffects();
  }

  /// Apply equalizer settings to audio system
  Future<void> _applyEqualizerSettings() async {
    if (!state.isEnabled) return;
    
    try {
      // TODO: Implement actual audio system integration
      // This would typically use platform-specific audio APIs
      
      // For Android: AudioEffect.Equalizer
      // For iOS: AVAudioUnitEQ
      
      // Simulated implementation
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Example of how this might work:
      // await _audioEngine.setEqualizerBands(state.customValues);
      // await _audioEngine.setPreAmp(state.preAmp);
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to apply equalizer: $e');
    }
  }

  /// Apply audio effects to audio system
  Future<void> _applyAudioEffects() async {
    try {
      // TODO: Implement actual audio effects
      // This would apply bass boost, virtualizer, and loudness enhancer
      
      // Simulated implementation
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Example of how this might work:
      // await _audioEngine.setBassBoost(state.bassBoost);
      // await _audioEngine.setVirtualizer(state.virtualizer);
      // await _audioEngine.setLoudnessEnhancer(state.loudnessEnhancer);
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to apply audio effects: $e');
    }
  }

  /// Expand 5-band preset values to 10-band
  List<double> _expandValues(List<double> fiveBandValues) {
    if (fiveBandValues.length >= 10) {
      return fiveBandValues.take(10).toList();
    }
    
    // Interpolate 5-band to 10-band
    final expanded = <double>[];
    for (int i = 0; i < 10; i++) {
      final position = (i / 9) * (fiveBandValues.length - 1);
      final index = position.floor();
      final fraction = position - index;
      
      if (index >= fiveBandValues.length - 1) {
        expanded.add(fiveBandValues.last);
      } else {
        final value = fiveBandValues[index] + 
            (fiveBandValues[index + 1] - fiveBandValues[index]) * fraction;
        expanded.add(value);
      }
    }
    
    return expanded;
  }

  /// Get frequency labels for 10-band equalizer
  static List<String> getFrequencyLabels() {
    return [
      '31Hz',
      '62Hz',
      '125Hz',
      '250Hz',
      '500Hz',
      '1kHz',
      '2kHz',
      '4kHz',
      '8kHz',
      '16kHz',
    ];
  }

  /// Get available presets with their values
  List<EqualizerPresetExtended> getAvailablePresets() {
    return [
      EqualizerPresetExtended(
        name: 'normal',
        displayName: 'Normal',
        values: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        description: 'Flat response',
      ),
      EqualizerPresetExtended(
        name: 'rock',
        displayName: 'Rock',
        values: [3.0, 2.0, 1.0, -1.0, -0.5, 1.0, 2.0, 3.0, 3.5, 4.0],
        description: 'Enhanced bass and treble',
      ),
      EqualizerPresetExtended(
        name: 'pop',
        displayName: 'Pop',
        values: [-1.0, 0.0, 2.0, 3.0, 2.0, 1.0, 0.0, -1.0, -1.5, -2.0],
        description: 'Vocal clarity',
      ),
      EqualizerPresetExtended(
        name: 'jazz',
        displayName: 'Jazz',
        values: [2.0, 1.5, 1.0, 0.5, 0.0, 0.5, 1.0, 2.0, 2.5, 3.0],
        description: 'Warm and smooth',
      ),
      EqualizerPresetExtended(
        name: 'classical',
        displayName: 'Classical',
        values: [3.0, 2.5, 2.0, 1.0, -1.0, -1.5, 0.0, 1.5, 2.5, 3.5],
        description: 'Natural orchestral sound',
      ),
      EqualizerPresetExtended(
        name: 'bass_boost',
        displayName: 'Bass Boost',
        values: [6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0, 0.0, 0.0, 0.0],
        description: 'Heavy bass emphasis',
      ),
      EqualizerPresetExtended(
        name: 'treble_boost',
        displayName: 'Treble Boost',
        values: [0.0, 0.0, 0.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0],
        description: 'Enhanced high frequencies',
      ),
      EqualizerPresetExtended(
        name: 'vocal',
        displayName: 'Vocal',
        values: [-2.0, -1.0, 0.0, 2.0, 4.0, 4.5, 3.0, 1.0, 0.0, -1.0],
        description: 'Clear vocal presence',
      ),
      EqualizerPresetExtended(
        name: 'electronic',
        displayName: 'Electronic',
        values: [4.0, 3.0, 1.0, 0.0, -1.0, 0.0, 1.0, 2.0, 4.0, 5.0],
        description: 'Synthetic music enhancement',
      ),
      EqualizerPresetExtended(
        name: 'acoustic',
        displayName: 'Acoustic',
        values: [2.0, 1.5, 1.0, 0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 1.0],
        description: 'Natural acoustic instruments',
      ),
    ];
  }
}

/// Extended equalizer preset with additional information
class EqualizerPresetExtended {
  const EqualizerPresetExtended({
    required this.name,
    required this.displayName,
    required this.values,
    required this.description,
  });

  final String name;
  final String displayName;
  final List<double> values;
  final String description;
}

/// Provider for equalizer controller
final equalizerControllerProvider = 
    StateNotifierProvider<EqualizerController, EqualizerState>(
  (ref) => EqualizerController(ref),
);
