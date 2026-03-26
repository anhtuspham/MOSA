import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mosa/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> nativeGoogleSignIn() async {
  final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  final scopes = ['email', 'profile'];
  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize(serverClientId: webClientId, clientId: iosClientId);

  // Clear any existing session to prevent cached token issues leading to Account reauth failed 
  await googleSignIn.signOut();

  final googleUser = await googleSignIn.authenticate();

  /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
  /// while also granting permission to access user information.
  final authorization =
      await googleUser.authorizationClient.authorizationForScopes(scopes) ??
      await googleUser.authorizationClient.authorizeScopes(scopes);

  final idToken = googleUser.authentication.idToken;

  if (idToken == null) {
    throw AuthException('No ID Token found.');
  }

  await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: authorization.accessToken,
  );
}
