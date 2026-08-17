import 'package:flutter/material.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/complaint/complaint.dart';
import 'package:bigpay/data/models/complaint/complaint_category.dart';
import 'package:bigpay/models/actions/complaints/get_complaint_categories_action.dart';
import 'package:bigpay/models/actions/complaints/submit_complaint_action.dart';
import 'package:bigpay/routes/app_router.dart';
import 'package:bigpay/ui/components/forms/forms.dart';
import 'package:bigpay/ui/components/process_builder.dart';
import 'package:bigpay/ui/layouts/main.lo.dart';
import 'package:bigpay/ui/theme/app_theme.dart';
import 'package:bigpay/ui/theme/app_typography.dart';
import 'package:bigpay/utils/message.util.dart';

/// The new-complaint form: pick a category (from `complaintCategories`), add a
/// subject and a message, and open the complaint via `submitComplaint`.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  static PageRouteDefinition route = PageRouteDefinition(
    path: '/services/feedback',
  );

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _categoryController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _subjectFocusNode = FocusNode();

  final _canSubmit = ValueNotifier(false);

  ExecuteProcessEvent? _categoriesEvent;
  ExecuteProcessEvent? _submitEvent;

  List<ComplaintCategory> _categories = const [];
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _categoryController,
      _subjectController,
      _messageController,
    ]) {
      controller.addListener(_recompute);
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _subjectFocusNode.dispose();
    _canSubmit.dispose();
    super.dispose();
  }

  void _recompute() {
    _canSubmit.value =
        _categoryId != null &&
        _subjectController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty;
  }

  void _loadCategories() {
    _categoriesEvent = context.dispatchProcess(
      const GetComplaintCategoriesAction(),
      returnSavedResponse: true,
      saveActionResponse: true,
    );
  }

  void _onCategorySelected(String label) {
    _categoryId = _categories
        .where((c) => c.name == label)
        .map((c) => c.id)
        .firstOrNull;
    _recompute();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _submitEvent = context.dispatchProcess(
      SubmitComplaintAction(
        payload: SubmitComplaintPayload(
          categoryId: _categoryId,
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProcessListener(
      listeners: [
        ProcessListenerConfig<List<ComplaintCategory>>(
          event: () => _categoriesEvent,
          listener: (context, snapshot) {
            if (snapshot.hasData) {
              setState(() => _categories = snapshot.data ?? const []);
            }
          },
        ),
        ProcessListenerConfig<Complaint>(
          event: () => _submitEvent,
          listener: (context, snapshot) {
            if (snapshot.isLoading) {
              MessageUtil.displayLoading(context);
              return;
            }
            MessageUtil.close(context);

            if (snapshot.isSuccessful) {
              _submitEvent = null;
              MessageUtil.displaySuccessDialog(
                context,
                message:
                    snapshot.message ?? 'Your complaint has been submitted.',
                onOk: () => AppRouter.router.pop(),
              );
              return;
            }

            if (snapshot.hasError) {
              _submitEvent = null;
              MessageUtil.displayErrorDialog(
                context,
                message: snapshot.error!.message,
              );
            }
          },
        ),
      ],
      child: MainLayout(
        bottomSize: 112,
        title: 'Report an Issue',
        subtitle:
            'Encountered a problem? Tell us what went wrong, and our support team will get straight to work to resolve it for you.',
        bottomNav: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            Row(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Icon(Icons.timer, size: 20, color: AppColors.flora),
                const SizedBox(width: 2),
                Text(
                  'Our team typically responds within 2 hours.',
                  style: AppTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: _canSubmit,
              builder: (context, canSubmit, child) {
                return FormButton(
                  enabled: canSubmit,
                  onPressed: _submit,
                  text: 'Send Message',
                );
              },
            ),
          ],
        ),
        child: Form(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              FormSelectInput(
                label: 'Select a category',
                placeholder: 'Search...',
                controller: _categoryController,
                onChanged: _onCategorySelected,
                next: (_) => _subjectFocusNode.requestFocus(),
                options: [
                  for (final category in _categories)
                    FormSelectOption(
                      id: category.id ?? '',
                      label: category.name ?? '',
                    ),
                ],
              ),
              SizedBox(height: 15),
              FormInput(
                label: 'Subject',
                controller: _subjectController,
                focusNode: _subjectFocusNode,
              ),
              SizedBox(height: 15),
              FormTextAreaInput(
                label: 'Message',
                placeholder: 'Details of your challenge here',
                controller: _messageController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
