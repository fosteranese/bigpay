import 'package:equatable/equatable.dart';

/// A complaint category from `MyAccount/complaintCategories`, used to populate
/// the picker on the new-complaint form.
class ComplaintCategory extends Equatable {
  const ComplaintCategory({this.id, this.name});

  final String? id;
  final String? name;

  factory ComplaintCategory.fromMap(Map<String, dynamic> data) =>
      ComplaintCategory(
        id: (data['id'] ??
                data['categoryId'] ??
                data['catId'] ??
                data['complaintCategoryId'] ??
                data['code'] ??
                data['value'])
            ?.toString(),
        name: (data['name'] ??
                data['categoryName'] ??
                data['catName'] ??
                data['complaintCategoryName'] ??
                data['description'] ??
                data['title'] ??
                data['tile'] ??
                data['label'])
            ?.toString(),
      );

  @override
  List<Object?> get props => [id, name];
}
