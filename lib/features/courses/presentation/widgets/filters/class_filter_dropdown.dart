import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/class_filter_error.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/class_filter_loaded.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/class_filter_loading.dart';

class ClassFilterDropdown extends StatelessWidget {
  const ClassFilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassesLoading) {
          return const ClassFilterLoading();
        } else if (state is ClassesError) {
          return const ClassFilterError();
        } else if (state is ClassesLoaded) {
          return ClassFilterLoaded(
            classes: state.classes,
            selectedClass: state.selectedClass,
          );
        }
        // Fallback UI
        return const ClassFilterLoading();
      },
    );
  }
}

