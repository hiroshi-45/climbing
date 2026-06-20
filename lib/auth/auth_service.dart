import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication の薄いラッパ。
///
/// 同期は「サインイン済み（uid あり）かつプレミアム」のときだけ起動する。
/// まずは疎通確認用に匿名サインインを用意し、Apple / Google サインインは
/// 認証 UI のステップで本サービスに足していく。
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// サインイン状態の変化（uid の発行/失効）を監視する。
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// 現在の UID（未サインインなら null）。同期のデータ隔離キーに使う。
  String? get uid => _auth.currentUser?.uid;

  bool get isSignedIn => _auth.currentUser != null;

  /// 疎通確認・お試し用の匿名サインイン。後から正規アカウントへ昇格できる。
  Future<String> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  Future<void> signOut() => _auth.signOut();
}
