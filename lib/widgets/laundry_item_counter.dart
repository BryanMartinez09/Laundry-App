import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LaundryItemCounter extends StatelessWidget {
  final String name;
  final String? size;
  final int standardCount;
  final int colorCount;
  final Function(int) onStandardChanged;
  final Function(int) onColorChanged;

  const LaundryItemCounter({
    super.key,
    required this.name,
    this.size,
    required this.standardCount,
    required this.colorCount,
    required this.onStandardChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (size != null)
                      Text(
                        size!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Standard Column
              Expanded(
                child: _buildCounterColumn(
                  'ESTÁNDAR',
                  standardCount,
                  onStandardChanged,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Color Column
              Expanded(
                child: _buildCounterColumn(
                  'COLOR',
                  colorCount,
                  onColorChanged,
                  Colors.pink[400]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterColumn(String label, int value, Function(int) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: color.withOpacity(0.5), size: 28),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: color, size: 28),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
