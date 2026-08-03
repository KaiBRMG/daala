/// Screen 5 — profile details, the last step of signup.
///
/// Two things happen on "Complete Setup", in this order:
///
/// 1. **One atomic batch** writes the public card, the private contact record,
///    and the consent evidence captured back on the phone screen. A batch means
///    a half-written profile is impossible.
/// 2. **A sign-in link is sent to the email**, and the user carries on into the
///    app. Opening that link later *links the email credential onto this same
///    account* — see [AuthRepository.completeEmailLink]. Without that link step
///    a later email login would mint a second uid with its own wallet, which is
///    the defect phase2.md's original design would have shipped.
///
/// The email send is fire-and-forget on purpose: a failed send must never block
/// someone from finishing onboarding, and they can always retry from the email
/// login screen.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../auth/legal.dart';
import '../../auth/phone_format.dart';
import '../../auth/signup_flow.dart';
import '../../auth/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _day = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();

  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();

  UserGoal? _goal;
  bool _saving = false;
  String? _error;

  /// Set on the email-first path, where the account already carries a verified
  /// address. Asking for it again would be asking someone to retype the thing
  /// they just proved they own.
  String? _accountEmail;

  /// Set once the user has tried to submit — until then the form stays quiet
  /// rather than scolding someone who is still typing.
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _accountEmail = ref.read(authRepositoryProvider).currentUser?.email;
    for (final controller in [_firstName, _lastName, _email]) {
      controller.addListener(_refresh);
    }
    for (final focus in [_firstFocus, _lastFocus, _emailFocus, _dayFocus, _monthFocus, _yearFocus]) {
      focus.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _email,
      _day,
      _month,
      _year,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _firstFocus,
      _lastFocus,
      _emailFocus,
      _dayFocus,
      _monthFocus,
      _yearFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  DateTime? get _birthDate =>
      parseBirthDate(_day.text, _month.text, _year.text);

  /// Returns the first blocking problem in plain language, or `null`.
  String? get _validationMessage {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      return 'Please add your first and last name.';
    }
    if (_accountEmail == null && !looksLikeEmail(_email.text)) {
      return 'That email address looks incomplete. Check it and try again.';
    }
    final dob = _birthDate;
    if (dob == null) {
      return 'Please enter your date of birth as day, month and year.';
    }
    if (!isOfAge(dob)) {
      return 'You need to be $kMinimumAge or older to use Daala. '
          'That is a requirement of holding money in escrow.';
    }
    if (_goal == null) return 'Pick what brings you to Daala.';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _showValidation = true);
    final problem = _validationMessage;
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final draft = ref.read(signupDraftProvider);
    final terms = ref.read(legalTermsProvider).value ?? LegalTerms.fallback;
    final email = _accountEmail ?? _email.text.trim();
    final lastName = _lastName.text.trim();

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.createProfile(
        uid: user.uid,
        profile: UserProfile(
          uid: user.uid,
          firstName: _firstName.text.trim(),
          lastInitial: lastName.isEmpty ? '' : lastName[0].toUpperCase(),
          goal: _goal!,
          termsVersion: draft.termsVersion ?? terms.termsVersion,
        ),
        contact: UserContact(
          lastName: lastName,
          dateOfBirth: _birthDate!,
          email: email,
          phoneNumber: user.phoneNumber,
        ),
        consent: ConsentRecord(
          termsVersion: draft.termsVersion ?? terms.termsVersion,
          privacyVersion: draft.privacyVersion ?? terms.privacyVersion,
          source: 'signup',
          // Captured back on the phone screen, when they tapped under the
          // consent line. Falls back to now only if the flow was resumed.
          acceptedAt: draft.consentAcceptedAt ?? DateTime.now(),
        ),
      );

      // Fire-and-forget: verifying the email links it to this account, but a
      // send failure must not strand a finished signup. Skipped entirely on the
      // email-first path — that address is already a credential on this uid, so
      // a link would confirm what is already true.
      if (_accountEmail == null) {
        unawaited(_sendVerificationLink(email));
      }

      ref.read(signupDraftProvider.notifier).reset();
      // No manual navigation — the session recomputes and the router moves on.
      await ref.read(sessionProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = describeAuthError(error).message;
        _saving = false;
      });
    }
  }

  Future<void> _sendVerificationLink(String email) async {
    try {
      await ref.read(pendingEmailStoreProvider).savePendingEmail(email);
      await ref.read(authRepositoryProvider).sendEmailSignInLink(email);
    } catch (_) {
      /* Retryable from the email login screen. */
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'A few more things',
      subtitle:
          'This is what people see when you post a gig or offer to do one.',
      progress: 1,
      trailing: Text('Final step', style: AppText.label),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            InlineNotice(_error!, emphasis: true),
            const SizedBox(height: AppSpacing.lg),
          ],
          GwButton(
            label: 'Complete Setup',
            // Green: this is a committing, account-creating action.
            tone: GwButtonTone.green,
            loading: _saving,
            // Stays tappable while incomplete so tapping explains what's
            // missing, rather than leaving a dead button and no reason why.
            onTap: _saving ? null : _submit,
          ),
        ],
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TextFieldShell(
                label: 'First name',
                controller: _firstName,
                focusNode: _firstFocus,
                hint: 'Thandi',
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                onSubmitted: (_) => _lastFocus.requestFocus(),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _TextFieldShell(
                label: 'Last name',
                controller: _lastName,
                focusNode: _lastFocus,
                hint: 'Mokoena',
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.familyName],
                onSubmitted: (_) => _emailFocus.requestFocus(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Other people see your first name and last initial only.',
          style: AppText.meta,
        ),
        const SizedBox(height: AppSpacing.xl4),
        if (_accountEmail case final confirmed?) ...[
          Text('Email address', style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
          _ConfirmedEmail(email: confirmed),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Already confirmed — it’s your backup way in if you ever lose '
            'your phone.',
            style: AppText.meta.copyWith(height: 1.45),
          ),
        ] else ...[
          _TextFieldShell(
            label: 'Email address',
            controller: _email,
            focusNode: _emailFocus,
            hint: 'thandi@example.co.za',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _dayFocus.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll send a link to confirm it. It becomes your backup way in if "
            'you ever lose your phone.',
            style: AppText.meta.copyWith(height: 1.45),
          ),
        ],
        const SizedBox(height: AppSpacing.xl4),
        Text('Date of birth', style: AppText.label),
        const SizedBox(height: AppSpacing.sm),
        _BirthDateRow(
          day: _day,
          month: _month,
          year: _year,
          dayFocus: _dayFocus,
          monthFocus: _monthFocus,
          yearFocus: _yearFocus,
          onChanged: _refresh,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You must be $kMinimumAge or older. We never show your birthday.',
          style: AppText.meta,
        ),
        const SizedBox(height: AppSpacing.xl4),
        Text('What brings you to Daala?', style: AppText.label),
        const SizedBox(height: AppSpacing.md),
        TwoOptionSelector<UserGoal>(
          options: const [
            (UserGoal.makeMoney, 'Make Money'),
            (UserGoal.getThingsDone, 'Get Things Done'),
          ],
          selected: _goal,
          subtitleBuilder: (goal) => goal == UserGoal.makeMoney
              ? 'Find gigs to do'
              : 'Get help with a task',
          onChanged: (goal) => setState(() {
            _goal = goal;
            if (_showValidation) _error = _validationMessage;
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'You can do both on Daala — this just sets where you start.',
          style: AppText.meta,
        ),
      ],
    );
  }
}

/// The already-verified address, shown in the same white card the editable
/// fields use so the form still reads as one column, with a check that says why
/// it isn't editable.
class _ConfirmedEmail extends StatelessWidget {
  const _ConfirmedEmail({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return FieldShell(
      child: Row(
        children: [
          Expanded(
            child: Text(
              email,
              style: AppText.value.copyWith(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }
}

/// A labelled text field inside the system's white field card.
class _TextFieldShell extends StatelessWidget {
  const _TextFieldShell({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return FieldShell(
      label: label,
      focused: focusNode.hasFocus,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        textInputAction: TextInputAction.next,
        onSubmitted: onSubmitted,
        cursorColor: AppColors.green,
        style: AppText.value.copyWith(fontSize: 16),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          // ink-55, per The Readable-Muted Rule — a fainter placeholder fails
          // contrast in exactly the daylight this app is used in.
          hintStyle: AppText.value.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.ink55,
          ),
        ),
      ),
    );
  }
}

/// `DD | MM | YYYY` as three auto-advancing cells.
///
/// A calendar picker means swiping back through ~300 months to reach a birth
/// year; typing six digits is faster for everyone and far faster one-handed.
class _BirthDateRow extends StatelessWidget {
  const _BirthDateRow({
    required this.day,
    required this.month,
    required this.year,
    required this.dayFocus,
    required this.monthFocus,
    required this.yearFocus,
    required this.onChanged,
  });

  final TextEditingController day;
  final TextEditingController month;
  final TextEditingController year;
  final FocusNode dayFocus;
  final FocusNode monthFocus;
  final FocusNode yearFocus;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _DateCell(
            controller: day,
            focusNode: dayFocus,
            hint: 'DD',
            length: 2,
            semanticLabel: 'Day of birth',
            onFilled: monthFocus.requestFocus,
            onEmptyBackspace: null,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: _DateCell(
            controller: month,
            focusNode: monthFocus,
            hint: 'MM',
            length: 2,
            semanticLabel: 'Month of birth',
            onFilled: yearFocus.requestFocus,
            onEmptyBackspace: dayFocus.requestFocus,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 4,
          child: _DateCell(
            controller: year,
            focusNode: yearFocus,
            hint: 'YYYY',
            length: 4,
            semanticLabel: 'Year of birth',
            onFilled: () => FocusScope.of(context).unfocus(),
            onEmptyBackspace: monthFocus.requestFocus,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _DateCell extends StatefulWidget {
  const _DateCell({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.length,
    required this.semanticLabel,
    required this.onFilled,
    required this.onEmptyBackspace,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int length;
  final String semanticLabel;
  final VoidCallback onFilled;

  /// Backspace in an already-empty cell steps focus back — without it, deleting
  /// a mistyped date means tapping each cell by hand.
  final VoidCallback? onEmptyBackspace;
  final VoidCallback onChanged;

  @override
  State<_DateCell> createState() => _DateCellState();
}

class _DateCellState extends State<_DateCell> {
  /// Owned rather than built inline: a [FocusNode] created in `build` is
  /// re-allocated every frame and never disposed.
  final FocusNode _keyListenerNode =
      FocusNode(skipTraversal: true, canRequestFocus: false);

  @override
  void dispose() {
    _keyListenerNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final focusNode = widget.focusNode;

    return Semantics(
      label: widget.semanticLabel,
      child: KeyboardListener(
        focusNode: _keyListenerNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            widget.onEmptyBackspace?.call();
          }
        },
        child: FieldShell(
          focused: focusNode.hasFocus,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            cursorColor: AppColors.green,
            style:
                AppText.value.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            onChanged: (value) {
              widget.onChanged();
              if (value.length == widget.length) widget.onFilled();
            },
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: AppText.value.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.ink55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
