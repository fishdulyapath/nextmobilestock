import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobilestock/core/service_locator.dart';
import 'package:mobilestock/repository/authentication_repository.dart';
import 'package:mobilestock/global.dart' as global;

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<AuthenticationLoggedIn>(_onLoggedIn);
    on<AuthenticationLoggedOut>(_onLoggedOut);
  }
  void _onLoggedIn(AuthenticationLoggedIn event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationInProgress());
    try {
      final result = await serviceLocator<AuthRepository>().authenUser(event.username, event.password, event.provider, event.dbName);
      if (result.success) {
        // บันทึกลง SharedPreferences
        await global.saveConfigToPrefs(
          usercode: event.username,
          username: event.username,
          provider: event.provider,
          dbname: event.dbName,
        );
        emit(AuthenticationSuccess(result.data));
      } else {
        emit(AuthenticationError(result.message));
      }
    } catch (e) {
      emit(AuthenticationError(e.toString()));
      return;
    }
  }

  void _onLoggedOut(AuthenticationLoggedOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationInProgress());
    try {
      // ล้างข้อมูล user จาก SharedPreferences
      await global.clearUserData();
      emit(AuthenticationLogout());
    } catch (e) {
      emit(AuthenticationError(e.toString()));
      return;
    }
  }
}
