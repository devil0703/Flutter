class ValidatorService {
  validateEmail(String email) {
    if (email.isEmpty) {
      return "Cannot be empty";
    }
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) ? null : 'Invalid Email';
  }

  validateText(String text) {
    if (text.isEmpty) {
      return "Cannot be empty";
    }
  }
}
