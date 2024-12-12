String doctypeDetailUrl(String doctype, String name) {
  return '/api/resource/$doctype/$name';
}

String globalDefaultsUrl() {
  return '/api/resource/Global%20Defaults/Global%20Defaults';
}

String itemDataUrl(String text) {
  return '/api/resource/Item/$text';
}

String loginUrl() {
  return '/api/method/login';
}

String logoutUrl() {
  return '/api/method/logout';
}

String salesOrderUrl() {
  return '/api/resource/Sales%20Order';
}

String usernameUrl() {
  return '/api/method/frappe.auth.get_logged_user';
}

String pricelistUrl(String pricelist) {
  return '/api/resource/Price%20List/$pricelist';
}

String userUrl(String email) {
  return '/api/resource/User/$email';
}
