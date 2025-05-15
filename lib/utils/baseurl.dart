class UrlUtils {
  // Các môi trường khác nhau
  static const String PRODUCTION = "PRODUCTION";
  static const String DEVELOPMENT = "DEVELOPMENT";
  static const String PERSONAL = "PERSONAL"; // Môi trường cá nhân của bạn

  // Môi trường hiện tại - đổi giá trị này để chuyển môi trường
  static const String CURRENT_ENV = PERSONAL;

  static String getBaseUrl() {
    switch (CURRENT_ENV) {
      case PRODUCTION:
        return "http://172.11.250.156:3000/"; // URL chính thức
      case DEVELOPMENT:
        return "http://172.11.250.156:3000/"; // URL phát triển/staging
      case PERSONAL:
        return "http://172.11.250.156:3000/"; // URL môi trường cá nhân của bạn
      default:
        return "http://172.11.250.156:3000/"; // Mặc định về môi trường chính
    }
  }

  // Phương thức để lấy tên môi trường hiện tại
  static String getCurrentEnvName() {
    switch (CURRENT_ENV) {
      case PRODUCTION:
        return "Production";
      case DEVELOPMENT:
        return "Development";
      case PERSONAL:
        return "Personal";
      default:
        return "Unknown";
    }
  }
}
