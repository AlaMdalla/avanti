import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_formateurs.dart';
import '../../domain/usecases/add_formateur.dart';
import 'formateur_event.dart';
import 'formateur_state.dart';

class FormateurBloc extends Bloc<FormateurEvent, FormateurState> {
  final GetAllFormateurs getAllFormateurs;
  final AddFormateur addFormateur;

  FormateurBloc({
    required this.getAllFormateurs,
    required this.addFormateur,
  }) : super(FormateurInitial()) {
    on<LoadFormateurs>((event, emit) async {
      emit(FormateurLoading());
      try {
        final list = await getAllFormateurs.call();
        emit(FormateurLoaded(list));
      } catch (e) {
        emit(FormateurError(e.toString()));
      }
    });

    on<AddFormateurEvent>((event, emit) async {
      try {
        await addFormateur.call(event.formateur);
        final list = await getAllFormateurs.call();
        emit(FormateurLoaded(list));
      } catch (e) {
        emit(FormateurError(e.toString()));
      }
    });
  }
}
