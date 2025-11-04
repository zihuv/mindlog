class WebDAVConfig {
  final String serverUrl;
  final String username;
  final String password;
  final String remotePath;

  WebDAVConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.remotePath = '/think_track/',
  });

  WebDAVConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? remotePath,
  }) {
    return WebDAVConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'remotePath': remotePath,
    };
  }

  factory WebDAVConfig.fromMap(Map<String, dynamic> map) {
    return WebDAVConfig(
      serverUrl: map['serverUrl'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      remotePath: map['remotePath'] ?? '/think_track/',
    );
  }
}