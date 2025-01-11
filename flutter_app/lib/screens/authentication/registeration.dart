// ignore_for_file: invalid_use_of_visible_for_testing_member, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/constants/registration_consts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/home_screen.dart';
import 'package:flutter_app/models/users_models.dart';
import 'package:flutter_app/providers/users_providers.dart';
import 'package:flutter_app/utils/snackbar_util.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isLoading = false;
  String _selectedUserType = 'investor';
  String? _selectedAgeGroup;
  String? _selectedEmploymentStatus;
  String? _selectedIncomeRange;
  String? _selectedRiskLevel;
  final Set<String> _selectedIndustries = {};
  final Set<String> _selectedShortTermGoals = {};
  final Set<String> _selectedInvestmentInterests = {};
  final Set<String> _selectedChallenges = {};

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ref.read(userProvider.notifier).state = UserModel(
          userId: _usernameController.text.trim(),
          email: ref.read(userProvider).email,
          phoneNumber: _phoneController.text.trim(),
          displayName: _nameController.text.trim(),
          role: _selectedUserType,
          profileCompleted: true,
          additionalData: {
            'ageGroup': _selectedAgeGroup,
            'employmentStatus': _selectedEmploymentStatus,
            'incomeRange': _selectedIncomeRange,
            'riskLevel': _selectedRiskLevel,
            'industries': _selectedIndustries.toList(),
            'shortTermGoals': _selectedShortTermGoals.toList(),
            'investmentInterests': _selectedInvestmentInterests.toList(),
            'challenges': _selectedChallenges.toList(),
          },
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(ref.read(userProvider).email)
            .set(ref.read(userProvider).toFirestore());

        showSnackBar(context, 'Registration successful');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'Registration failed');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  Widget _buildChipSelection({
    required String label,
    required List<String> options,
    required Set<String> selectedItems,
    int? maxSelection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              selected: isSelected,
              label: Text(item),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    if (maxSelection == null ||
                        selectedItems.length < maxSelection) {
                      selectedItems.add(item);
                    }
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
              selectedColor: Colors.green,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // User Type Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text('Investor'),
                      selectedColor: Colors.green,
                      selected: _selectedUserType == 'investor',
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedUserType = 'investor';
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ChoiceChip(
                      label: Text('Business'),
                      selectedColor: Colors.green,
                      selected: _selectedUserType == 'business',
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedUserType = 'business';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Basic Information
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                              r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers and underscore';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Demographics
                _buildDropdown(
                  label: 'Age Group',
                  value: _selectedAgeGroup,
                  items: ageGroups,
                  onChanged: (value) =>
                      setState(() => _selectedAgeGroup = value),
                ),
                const SizedBox(height: 20),

                _buildDropdown(
                  label: 'Employment Status',
                  value: _selectedEmploymentStatus,
                  items: employmentStatuses,
                  onChanged: (value) =>
                      setState(() => _selectedEmploymentStatus = value),
                ),
                const SizedBox(height: 20),

                _buildDropdown(
                  label: 'Income Range',
                  value: _selectedIncomeRange,
                  items: incomeRanges,
                  onChanged: (value) =>
                      setState(() => _selectedIncomeRange = value),
                ),
                const SizedBox(height: 20),

                _buildDropdown(
                  label: 'Risk Appetite',
                  value: _selectedRiskLevel,
                  items: riskLevels,
                  onChanged: (value) =>
                      setState(() => _selectedRiskLevel = value),
                ),
                const SizedBox(height: 30),

                Text(
                  "Short Term Goals",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildChipSelection(
                  label: 'Short Term Goals (Select up to 3)',
                  options: shortTermGoals,
                  selectedItems: _selectedShortTermGoals,
                  maxSelection: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  "Long Term Goals",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildChipSelection(
                  label: 'Long Term Goals',
                  options: longTermGoals,
                  selectedItems: _selectedChallenges,
                ),
                const SizedBox(height: 20),

                Text(
                  "Investment Interests",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                _buildChipSelection(
                  label: 'Investment Interests',
                  options: investmentInterests,
                  selectedItems: _selectedInvestmentInterests,
                ),
                const SizedBox(height: 20),
                Text(
                  "Favourite Sectors",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // const SizedBox(height: 10),
                _buildChipSelection(
                  label: 'Industries',
                  options: industries,
                  selectedItems: _selectedIndustries,
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Color.fromARGB(255, 0, 57, 103)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// // ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

// import 'package:flutter_app/consts.dart';
// import 'package:flutter_app/home_screen.dart';
// import 'package:flutter_app/models/users_models.dart';
// import 'package:flutter_app/providers/users_providers.dart';
// import 'package:flutter_app/utils/snackbar_util.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class RegistrationScreen extends ConsumerStatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   bool _isLoading = false;

//   String _selectedUserType = 'business';
//   final Set<String> _selectedIndustries = {};

//   Future<void> _register() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         ref.read(userProvider.notifier).state = UserModel(
//           userId: ref.read(userProvider).userId,
//           email: ref.read(userProvider).email,
//           phoneNumber: _phoneController.text.trim(),
//           displayName: _nameController.text.trim(),
//           role: _selectedUserType,
//           profileCompleted: true,
//           additionalData: {
//             'industries': _selectedIndustries.toList(),
//           },
//         );

//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(ref.read(userProvider).email)
//             .set(ref.read(userProvider).toFirestore());
//         showSnackBar(context, 'Registration successful');
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//           (Route<dynamic> route) => false,
//         );
//         return;
//       } on FirebaseAuthException catch (e) {
//         _showErrorDialog(e.message ?? 'Registration failed');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             child: Text('Okay'),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(height: 40),
//                   // Title
//                   Text(
//                     'Create Your Account',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 30),

//                   // User Type Selection
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ChoiceChip(
//                         label: Text('Investor'),
//                         selectedColor: Colors.green,
//                         selected: _selectedUserType == 'investor',
//                         onSelected: (bool selected) {
//                           setState(() {
//                             _selectedUserType = 'investor';
//                           });
//                         },
//                       ),
//                       SizedBox(width: 10),
//                       ChoiceChip(
//                         label: Text('Business'),
//                         selectedColor: Colors.green,
//                         selected: _selectedUserType == 'business',
//                         onSelected: (bool selected) {
//                           setState(() {
//                             _selectedUserType = 'business';
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Full Name',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your full name';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),

//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: InputDecoration(
//                       labelText: 'Phone Number',
//                       prefixIcon: Icon(Icons.phone),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     maxLength: 10,
//                     keyboardType: TextInputType.phone,
//                     validator: (value) {
//                       if (value != null && value.isNotEmpty) {
//                         // Optional phone number validation
//                         if (!RegExp(
//                                 r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$')
//                             .hasMatch(value)) {
//                           return 'Please enter a valid phone number';
//                         }
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),

//                   const Text(
//                     'Select Industry',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   // const SizedBox(height: 10),

//                   const SizedBox(height: 20),

//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _selectIndustry,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         side: const BorderSide(
//                             color: Color.fromARGB(255, 0, 57, 103)),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
//                             'Register',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _selectIndustry() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text('Select Industries'),
//         content: StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return SizedBox(
//               height: MediaQuery.of(context).size.height * 0.7,
//               child: SingleChildScrollView(
//                 child: Wrap(
//                   runAlignment: WrapAlignment.start,
//                   alignment: WrapAlignment.start,
//                   spacing: 4,
//                   runSpacing: 3,
//                   children: industries.map((industry) {
//                     final isSelected = _selectedIndustries.contains(industry);
//                     return FilterChip(
//                       selectedShadowColor: Colors.green,
//                       selectedColor: Colors.green,
//                       backgroundColor: Colors.grey[200],
//                       label: Text(
//                         industry,
//                         style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontSize: 12),
//                       ),
//                       selected: isSelected,
//                       onSelected: (bool selected) {
//                         setState(() {
//                           if (selected) {
//                             _selectedIndustries.add(industry);
//                           } else {
//                             _selectedIndustries.remove(industry);
//                           }
//                         });
//                         setState(() {});
//                       },
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 2, vertical: 2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//               child: Text('Register'),
//               onPressed: () {
//                 if (_selectedIndustries.isNotEmpty) _register();

//                 if (_selectedIndustries.isEmpty) {
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       content: Text(
//                         'Minimum one industry must be selected',
//                         style: TextStyle(fontSize: 16, color: Colors.red),
//                       ),
//                     ),
//                   );
//                 }
//               })
//         ],
//       ),
//       //   ],
//       // ),
//     );
//   }
// }
