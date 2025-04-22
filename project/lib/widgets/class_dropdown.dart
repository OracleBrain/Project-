import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/models/class_model.dart';

class ClassDropdown extends StatelessWidget {
  final List<ClassModel> classes;
  final ClassModel? selectedClass;
  final void Function(ClassModel?) onChanged;
  
  const ClassDropdown({
    super.key,
    required this.classes,
    this.selectedClass,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedClass?.id,
      decoration: InputDecoration(
        labelText: 'Select Class',
        hintText: 'Choose a class',
        prefixIcon: const Icon(Icons.class_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: classes.map((ClassModel classModel) {
        return DropdownMenuItem<String>(
          value: classModel.id,
          child: Text(
            '${classModel.name} (${classModel.courseCode})',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null) {
          final selectedClass = classes.firstWhere((c) => c.id == value);
          onChanged(selectedClass);
        } else {
          onChanged(null);
        }
      },
    );
  }
}