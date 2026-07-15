abstract final class Constants {
  static const String serviceName = 'org.freedesktop.secrets';

  // https://specifications.freedesktop.org/secret-service/latest-single/#id-1.3.3.2.4.3.4.2
  static const String defaultAlias = 'default';

  // Note: `secret-tool lookup` may report "secret does not contain a textual
  // password" for this content type due to a libsecret bug:
  // https://gitlab.gnome.org/GNOME/libsecret/-/work_items/114
  static const String secretTextContentType = 'text/plain; charset=utf-8';
}
