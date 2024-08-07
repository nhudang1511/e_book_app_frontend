import 'dart:async';

import 'package:e_book_app/config/shared_preferences.dart';
import 'package:e_book_app/exceptions/exceptions.dart';
import 'package:e_book_app/model/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repository/repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  Timer? timer;

  LoginCubit({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(LoginState.initial());

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        status: LoginStatus.initial,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        status: LoginStatus.initial,
      ),
    );
  }

  Future<void> logInWithCredentials() async {
    late String? deviceToken;
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      final credential = await _authRepository.logInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      if (credential != null) {
        SharedService.setUserId(credential.uid);
        if (credential.emailVerified == true) {
          deviceToken = await FirebaseMessaging.instance.getToken();
          _userRepository.updateDeviceToken(credential.uid, deviceToken!);
          emit(state.copyWith(status: LoginStatus.success));
        } else {
          await _authRepository.sendEmailVerification();
          verifyAccount(credential.uid);
        }
      }
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          exception: e.message,
        ),
      );
    }
  }

  Future<void> verifyAccount(String uId) async {
    late String? deviceToken;
    if (state.status == LoginStatus.verifying) return;
    emit(state.copyWith(status: LoginStatus.verifying));
    try {
      timer = Timer.periodic(const Duration(seconds: 3), (_) async {
        final isVerified = await _authRepository.isVerified();
        if (isVerified) {
          timer?.cancel();
          deviceToken = await FirebaseMessaging.instance.getToken();
          _userRepository.updateDeviceToken(uId, deviceToken!);
          emit(state.copyWith(status: LoginStatus.success));
        }
      });
    } catch (e) {
      emit(state.copyWith(
          status: LoginStatus.error, exception: 'Verification error.'));
    }
  }

  Future<void> unVerifyAccount() async {
    timer?.cancel();
    emit(state.copyWith(status: LoginStatus.unVerify));
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } on ServerException catch (e) {
      emit(state.copyWith(status: LoginStatus.error, exception: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: LoginStatus.error, exception: 'Verification error.'));
    }
  }

  Future<void> logInWithGoogle() async {
    late String? deviceToken;
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      final credential = await _authRepository.logInWithGoogle();
      if (credential != null) {
        await _userRepository.addUser(User.fromFirebaseUser(credential));
        deviceToken = await FirebaseMessaging.instance.getToken();
        _userRepository.updateDeviceToken(credential.uid, deviceToken!);
        emit(state.copyWith(status: LoginStatus.success));
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.error));
    }
  }

  Future<void> logInWithFacebook() async {
    late String? deviceToken;
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      final credential = await _authRepository.logInWithFacebook();
      if (credential != null) {
        _userRepository.addUser(User.fromFirebaseUser(credential));
        deviceToken = await FirebaseMessaging.instance.getToken();
        _userRepository.updateDeviceToken(credential.uid, deviceToken!);
        emit(state.copyWith(status: LoginStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          exception: e.toString(),
        ),
      );
    }
  }
}
