import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/start_quiz_attempt_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_quiz_questions_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_answer_use_case.dart';
import 'package:pythagoras/features/courses/domain/use_cases/submit_quiz_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/quiz/quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final StartQuizAttemptUseCase startQuizAttemptUseCase;
  final GetQuizQuestionsUseCase getQuizQuestionsUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final SubmitQuizUseCase submitQuizUseCase;

  QuizCubit({
    required this.startQuizAttemptUseCase,
    required this.getQuizQuestionsUseCase,
    required this.submitAnswerUseCase,
    required this.submitQuizUseCase,
  }) : super(QuizInitial());

  Future<void> startQuiz(int quizId) async {
    emit(QuizLoading());

    final attemptResult = await startQuizAttemptUseCase(quizId);
    
    await attemptResult.fold(
      (failure) async => emit(QuizError(failure.message)),
      (attempt) async {
        final questionsResult = await getQuizQuestionsUseCase(quizId);
        
        questionsResult.fold(
          (failure) => emit(QuizError(failure.message)),
          (questions) {
            emit(QuizLoaded(
              currentQuestionIndex: 0,
              attempt: attempt,
              questions: questions,
            ));
          },
        );
      },
    );
  }

  void selectOption(int questionId, int optionId) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final updatedOptions = Map<int, int?>.from(currentState.selectedOptions);
      updatedOptions[questionId] = optionId;
      emit(currentState.copyWith(selectedOptions: updatedOptions));
    }
  }

  void nextQuestion() {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  void previousQuestion() {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex > 0) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ));
      }
    }
  }

  Future<void> submitQuiz(int quizId) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      final answers = currentState.selectedOptions.entries.map((e) => {
        'question_id': e.key,
        'option_id': e.value,
      }).toList();

      final result = await submitQuizUseCase(
        quizId: quizId,
        answers: answers,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isSubmitting: false));
          emit(QuizError(failure.message));
        },
        (quizResult) {
          emit(QuizCompleted(quizResult));
        },
      );
    }
  }
}
