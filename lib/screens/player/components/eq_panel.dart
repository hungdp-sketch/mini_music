import 'package:flutter/material.dart';
import '../../../services/player/eq_service.dart';
import '../../../core/theme.dart';

class EqPanel extends StatefulWidget {
  const EqPanel({super.key});

  @override
  State<EqPanel> createState() => _EqPanelState();
}

class _EqPanelState extends State<EqPanel> {
  bool _isEnabled = EqService.instance.isEnabled;
  EqPreset _activePreset = EqService.instance.currentPreset;
  final List<double> _bandValues = List.filled(5, 0.0);
  bool _loadingBands = true;

  @override
  void initState() {
    super.initState();
    _loadBandValues();
  }

  Future<void> _loadBandValues() async {
    final gains = await EqService.instance.getBandGains();
    if (mounted) {
      setState(() {
        for (int i = 0; i < gains.length && i < 5; i++) {
          _bandValues[i] = gains[i];
        }
        _loadingBands = false;
      });
    }
  }

  Future<void> _applyPreset(EqPreset preset) async {
    setState(() => _activePreset = preset);
    final gains = EqService.instance.isEnabled
        ? await _applyAndGetGains(preset)
        : _getPresetGains(preset);
    if (mounted) {
      setState(() {
        for (int i = 0; i < gains.length && i < 5; i++) {
          _bandValues[i] = gains[i];
        }
      });
    }
  }

  Future<List<double>> _applyAndGetGains(EqPreset preset) async {
    await EqService.instance.applyPreset(preset);
    return await EqService.instance.getBandGains();
  }

  List<double> _getPresetGains(EqPreset preset) {
    const presets = {
      EqPreset.flat: [0.0, 0.0, 0.0, 0.0, 0.0],
      EqPreset.bassBoost: [6.0, 4.0, 0.0, 0.0, 0.0],
      EqPreset.trebleBoost: [0.0, 0.0, 0.0, 4.0, 6.0],
      EqPreset.rock: [4.0, 2.0, -1.0, 2.0, 4.0],
      EqPreset.pop: [-1.0, 3.0, 4.0, 3.0, -1.0],
    };
    return List<double>.from(presets[preset] ?? presets[EqPreset.flat]!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title + Toggle
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Equalizer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                _isEnabled ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isEnabled
                      ? AppTheme.primaryColor
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                  EqService.instance.enable(value);
                },
                activeThumbColor: AppTheme.primaryColor,
                activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Preset chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: EqPreset.values.map((preset) {
                final isActive = _activePreset == preset;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _isEnabled ? () => _applyPreset(preset) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppTheme.accentGradient : null,
                        color: isActive
                            ? null
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        preset.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(
                                  alpha: _isEnabled ? 0.65 : 0.3,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Band sliders
          _loadingBands
              ? const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (i) => _buildBandSlider(i)),
                ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBandSlider(int index) {
    final gain = _bandValues[index];
    final isPositive = gain > 0;

    return Column(
      children: [
        // Gain label
        Text(
          '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isPositive
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        // Vertical slider
        SizedBox(
          height: 140,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _isEnabled
                    ? AppTheme.primaryColor
                    : Colors.white24,
                inactiveTrackColor: Colors.white12,
                thumbColor: _isEnabled ? Colors.white : Colors.white38,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: _bandValues[index],
                min: -10.0,
                max: 10.0,
                onChanged: _isEnabled
                    ? (value) {
                        setState(() => _bandValues[index] = value);
                        EqService.instance.setBandGain(index, value);
                        // Clear preset selection when manually adjusting
                        setState(() => _activePreset = EqPreset.flat);
                      }
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Frequency label
        Text(
          EqService.bandLabels[index],
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
