abstract final class Constants {
  static const String serviceName = 'org.freedesktop.secrets';

  // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.2.4.3.4.2
  static const String defaultAlias = 'default';

  /// This is set to exactly `text/plain` and not `text/plain; charset=utf-8`,
  /// even though both are [permitted](https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.4.2.2.5.4)
  /// by the Secret Service specification for the following reasons:
  ///
  /// - `secret-tool lookup` may report `secret does not contain a textual password`
  ///   due to a [libsecret tool bug](https://gitlab.gnome.org/GNOME/libsecret/-/work_items/114).
  ///
  /// - `secret_value_get_text` from libsecret accepts only `text/plain`.
  ///   [Source](https://gnome.pages.gitlab.gnome.org/libsecret/method.Value.get_text.html#description).
  static const String secretTextContentType = 'text/plain';
}
