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
      emit(currentState.copyWith(
        selectedOptions: updatedOptions,
        actionError: null,
      ));
    }
  }

  Future<void> nextQuestion({int? quizId}) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final question = currentState.questions[currentState.currentQuestionIndex];
      final selectedOptionId = currentState.selectedOptions[question.id];

      // If an option is selected but hasn't been confirmed on the server yet:
      if (selectedOptionId != null &&
          currentState.submittedOptions[question.id] != selectedOptionId) {
        emit(currentState.copyWith(isSubmitting: true));

        final qId = quizId ?? int.tryParse(currentState.attempt.quizId) ?? 0;
        final attemptId = currentState.attempt.activeAttempt?.attemptId ?? currentState.attempt.id;

        final result = await submitAnswerUseCase(
          quizId: qId,
          quizAttemptId: attemptId,
          questionId: question.id,
          optionId: selectedOptionId,
        );

        result.fold(
          (failure) {
            emit(currentState.copyWith(
              isSubmitting: false,
              actionError: failure.message,
            ));
          },
          (answer) {
            final updatedSubmitted = Map<int, int>.from(currentState.submittedOptions);
            updatedSubmitted[question.id] = selectedOptionId;

            final nextIndex = currentState.currentQuestionIndex < currentState.questions.length - 1
                ? currentState.currentQuestionIndex + 1
                : currentState.currentQuestionIndex;

            emit(currentState.copyWith(
              isSubmitting: false,
              submittedOptions: updatedSubmitted,
              currentQuestionIndex: nextIndex,
            ));
          },
        );
        return;
      }

      // If already submitted or skipped, simply advance
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

      // Ensure the current question's answer is confirmed before finalizing the quiz
      if (currentState.questions.isNotEmpty &&
          currentState.currentQuestionIndex >= 0 &&
          currentState.currentQuestionIndex < currentState.questions.length) {
        final currentQuestion = currentState.questions[currentState.currentQuestionIndex];
        final currentOptionId = currentState.selectedOptions[currentQuestion.id];
        if (currentOptionId != null &&
            currentState.submittedOptions[currentQuestion.id] != currentOptionId) {
          final attemptId = currentState.attempt.activeAttempt?.attemptId ?? currentState.attempt.id;
          final answerResult = await submitAnswerUseCase(
            quizId: quizId,
            quizAttemptId: attemptId,
            questionId: currentQuestion.id,
            optionId: currentOptionId,
          );
          answerResult.fold(
            (failure) {
              // Keep going or inform
            },
            (answer) {
              final updatedSubmitted = Map<int, int>.from(currentState.submittedOptions);
              updatedSubmitted[currentQuestion.id] = currentOptionId;
              emit(currentState.copyWith(submittedOptions: updatedSubmitted));
            },
          );
        }
      }

      // Prepare final answers list with both answer_id and option_id
      final answers = currentState.selectedOptions.entries
          .where((e) => e.value != null)
          .map((e) => {
            'question_id': e.key,
            'answer_id': e.value,
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
