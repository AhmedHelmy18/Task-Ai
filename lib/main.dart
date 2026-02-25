import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whale_task/app/app.dart';
import 'package:whale_task/features/auth/data/repositories/auth_repository.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    demoProjectId: "demo-project-id",
  );

  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator("10.0.2.2", 9099);
    FirebaseFirestore.instance.useFirestoreEmulator("10.0.2.2", 8080);
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    FirebaseFunctions.instance.useFunctionsEmulator("10.0.2.2", 5001);
  }

  final authRepository = AuthRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: authRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(authRepository)..checkAuthStatus(),
          ),
        ],
        child: const TaskAi(),
      ),
    ),
  );
}
