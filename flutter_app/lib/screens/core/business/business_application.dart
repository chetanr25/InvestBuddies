// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessApplicationScreen extends ConsumerStatefulWidget {
  const BusinessApplicationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BusinessApplicationScreenState createState() =>
      _BusinessApplicationScreenState();
}

class _BusinessApplicationScreenState
    extends ConsumerState<BusinessApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numberOfLotsController = TextEditingController();
  final TextEditingController _pricePerLotController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _businessPlanController = TextEditingController();

  // Lists for dynamic inputs
  List<String> _tags = [];
  List<String> _financialDocuments = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: GestureDetector(
          // onTap: () => FocusScope.of(context).unfocus(),
          onVerticalDragCancel: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextFormField(
                controller: _titleController,
                label: 'Company name',
                hint: 'Enter your product title',
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              _buildMultilineTextFormField(
                controller: _descriptionController,
                label: 'Description of the product',
                hint: 'Provide a detailed description of your product',
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberFormField(
                      controller: _numberOfLotsController,
                      label: 'Number of Lots',
                      hint: 'Enter number of lots',
                      validator: (value) {
                        if (value!.isEmpty) return 'Number of lots is required';
                        if (int.tryParse(value) == null)
                          return 'Must be a valid number';
                        if (int.parse(value) <= 0)
                          return 'Must be greater than 0';
                        return null;
                      },
                      prefix: '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberFormField(
                      controller: _pricePerLotController,
                      label: 'Price per Lot',
                      hint: 'Enter price per lot',
                      validator: (value) {
                        if (value!.isEmpty) return 'Price per lot is required';
                        if (double.tryParse(value) == null)
                          return 'Must be a valid amount';
                        if (double.parse(value) <= 0)
                          return 'Must be greater than 0';
                        return null;
                      },
                      prefix: '\₹',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Total Funding Goal: \₹${_calculateTotalFunding()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTextFormField(
                controller: _industryController,
                label: 'Industry',
                hint: 'Enter your industry',
                validator: (value) =>
                    value!.isEmpty ? 'Industry is required' : null,
              ),
              _buildTagsSection(),
              const SizedBox(height: 16),
              _buildMultilineTextFormField(
                controller: _businessPlanController,
                label: 'Business Plan',
                hint: 'Provide an overview of your business plan',
              ),
              _buildDocumentUploadSection(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit Opportunity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildMultilineTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildNumberFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefix,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _calculateTotalFunding();
          });
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Tags',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // validator: validator,
                controller: _tagController,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addTag,
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: _tags
              .map((tag) => Chip(
                    backgroundColor: Colors.blue,
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.tag, color: Colors.white),
                    label: Text(tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        )),
                    onDeleted: () => _removeTag(tag),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Documents',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: _uploadDocument,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Document'),
        ),
        Wrap(
          spacing: 8,
          children: _financialDocuments
              .map((doc) => Chip(
                    label: Text(doc.split('/').last),
                    onDeleted: () => _removeDocument(doc),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.text = '';
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _uploadDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _financialDocuments.add(result.files.single.path!);
      });
    }
  }

  void _removeDocument(String document) {
    setState(() {
      _financialDocuments.remove(document);
    });
  }

  String _calculateTotalFunding() {
    double numberOfLots = double.tryParse(_numberOfLotsController.text) ?? 0;
    double pricePerLot = double.tryParse(_pricePerLotController.text) ?? 0;
    double total = numberOfLots * pricePerLot;

    String withCommas = '';
    String beforeDecimal = total.toString().split('.')[0];

    int counter = 0;
    for (int i = beforeDecimal.length - 1; i >= 0; i--) {
      if (counter == 3 && i != 0) {
        withCommas = ',${beforeDecimal[i]}$withCommas';
        counter = 1;
      } else if (counter == 2 && i != 0) {
        withCommas = ',${beforeDecimal[i]}$withCommas';
        counter = 0;
      } else {
        withCommas = beforeDecimal[i] + withCommas;
        counter++;
      }
    }

    return withCommas;
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      final encodedUserId =
          base64Encode(utf8.encode(ref.read(userProvider).userId!));

      final numberOfLots = int.parse(_numberOfLotsController.text);
      final pricePerLot = double.parse(_pricePerLotController.text);
      final totalFundingGoal = numberOfLots * pricePerLot;

      final businessData = {
        'userId': ref.read(userProvider).userId,
        'userEmail': ref.read(userProvider).email,
        'businessId': encodedUserId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'numberOfLots': numberOfLots,
        'pricePerLot': pricePerLot,
        'totalFundingGoal': totalFundingGoal,
        'currentFunding': 0.0,
        'industry': _industryController.text,
        'tags': _tags,
        'createdAt': DateTime.now(),
        'businessPlan': _businessPlanController.text,
        'financialDocuments': _financialDocuments,
        'email': ref.read(userProvider).email,
      };

      try {
        print('businessData: $businessData');
        await FirebaseFirestore.instance
            .collection('business')
            .doc(ref.read(userProvider).email!)
            .set(businessData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity submitted successfully')),
        );
        // Navigator.pop(context);
      } catch (e) {
        print('Error submitting opportunity: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting opportunity: $e')),
        );
      }
    }
  }
}
