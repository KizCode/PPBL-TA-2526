import 'package:flutter/material.dart';

import '../../../materials/models/material_model.dart';

class RecipeLine {
  int? materialId;
  String? materialName;
  String? unit;
  double qty;

  RecipeLine({
    this.materialId,
    this.materialName,
    this.unit,
    this.qty = 1,
  });
}

class RecipeInputWidget extends StatefulWidget {
  final List<MaterialModel> materials;
  final List<RecipeLine> initial;
  final ValueChanged<List<RecipeLine>> onChanged;

  const RecipeInputWidget({
    super.key,
    required this.materials,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<RecipeInputWidget> createState() => _RecipeInputWidgetState();
}

class _RecipeInputWidgetState extends State<RecipeInputWidget> {
  late List<RecipeLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = widget.initial.isEmpty ? [RecipeLine()] : [...widget.initial];
  }

  void _notify() {
    widget.onChanged(_lines);
  }

  void _addLine() {
    setState(() {
      _lines.add(RecipeLine());
    });
    _notify();
  }

  void _removeLine(int idx) {
    setState(() {
      _lines.removeAt(idx);
      if (_lines.isEmpty) _lines.add(RecipeLine());
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Resep (bahan penyusun)',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_lines.length, (idx) {
          final line = _lines[idx];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: line.materialId,
                    items: widget.materials
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: m.id,
                            child: Text('${m.name} (${m.unit})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      final selected = widget.materials
                          .where((m) => m.id == v)
                          .cast<MaterialModel?>()
                          .firstOrNull;
                      setState(() {
                        line.materialId = v;
                        line.materialName = selected?.name;
                        line.unit = selected?.unit;
                      });
                      _notify();
                    },
                    decoration: const InputDecoration(labelText: 'Bahan'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: line.qty.toString(),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Jumlah',
                            helperText: line.unit == null ? null : 'Satuan: ${line.unit}',
                          ),
                          onChanged: (v) {
                            final parsed =
                                double.tryParse(v.replaceAll(',', '.')) ?? 0;
                            line.qty = parsed;
                            _notify();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Hapus baris',
                        onPressed: () => _removeLine(idx),
                        icon: const Icon(Icons.remove_circle_outline),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
