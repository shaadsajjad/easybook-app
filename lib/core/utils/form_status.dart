/// Status of a form submission (login, register, edit profile, ...).
enum FormStatus {
  initial,
  submitting,
  success,
  failure;

  bool get isSubmitting => this == FormStatus.submitting;
}
