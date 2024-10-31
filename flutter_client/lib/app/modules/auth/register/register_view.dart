//file: \flutter_client\lib\app\modules\auth\register\register_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import '../../../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessNumberController =
      TextEditingController();
  final TextEditingController operatingHoursController =
      TextEditingController();
  final TextEditingController restaurantIdController = TextEditingController();

  final RxBool hasTables = true.obs;
  final RxInt tables = 0.obs;

  final RxBool isEmailDuplicate = false.obs;
  final RxBool isRestaurantIdDuplicate = false.obs;
  final RxBool isBusinessNumberDuplicate = false.obs;
  final RxBool _isPasswordHidden =
      true.obs; // Add this line to your RegisterView class
  RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Registration')),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email
                  Obx(() => TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@domain.com',
                          errorText: isEmailDuplicate.value
                              ? 'Email already in use'
                              : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            _checkDuplicateDebounced('email', value),
                      )),
                  // Password
                  Obx(() => TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              _isPasswordHidden.value =
                                  !_isPasswordHidden.value;
                            },
                          ),
                        ),
                        obscureText: _isPasswordHidden
                            .value, // Control the visibility of the password
                        validator: (value) =>
                            value!.isEmpty ? 'Password is required' : null,
                      )),
                  // Business Name
                  TextFormField(
                    controller: businessNameController,
                    decoration:
                        const InputDecoration(labelText: 'Business Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Business Name is required' : null,
                  ),
                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) =>
                        value!.isEmpty ? 'Address is required' : null,
                  ),
                  // Phone Number
                  TextFormField(
                    controller: phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      String formattedValue = formatPhoneNumber(value);
                      phoneNumberController.value = TextEditingValue(
                        text: formattedValue,
                        selection: TextSelection.collapsed(
                            offset: formattedValue.length),
                      );
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Phone Number is required' : null,
                  ),
                  // Business Number
                  Obx(() => TextFormField(
                        controller: businessNumberController,
                        decoration: InputDecoration(
                          labelText: 'Business Number',
                          hintText: '123-32-12345',
                          errorText: isBusinessNumberDuplicate.value
                              ? 'Business Number already in use'
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              final text = newValue.text;
                              if (text.length > 10) return oldValue;

                              String formattedText = text;
                              if (text.length >= 3) {
                                formattedText = '${text.substring(0, 3)}';
                                if (text.length >= 5) {
                                  formattedText += '-${text.substring(3, 5)}';
                                  if (text.length > 5) {
                                    formattedText +=
                                        '-${text.substring(5, text.length)}';
                                  }
                                } else {
                                  formattedText +=
                                      '-${text.substring(3, text.length)}';
                                }
                              }
                              return TextEditingValue(
                                text: formattedText,
                                selection: TextSelection.collapsed(
                                    offset: formattedText.length),
                              );
                            },
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Business Number is required';
                          }
                          final businessNumberRegex =
                              RegExp(r'^\d{3}-\d{2}-\d{5}$');
                          if (!businessNumberRegex.hasMatch(value)) {
                            return 'Enter a valid business number';
                          }
                          return null;
                        },
                        onChanged: (value) =>
                            _checkDuplicateDebounced('businessNumber', value),
                      )),
                  // Operating Hours
                  TextFormField(
                    controller: operatingHoursController,
                    decoration: const InputDecoration(
                        labelText: 'Operating Hours',
                        hintText: '09:00 - 23:00'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d|\:')),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) {
                          final text =
                              newValue.text.replaceAll(RegExp(r'\D'), '');
                          if (text.length > 8) return oldValue;

                          String formattedText = text;
                          if (text.length >= 4) {
                            formattedText =
                                '${text.substring(0, 2)}:${text.substring(2, 4)}';
                            if (text.length > 4) {
                              formattedText +=
                                  ' - ${text.substring(4, 6)}:${text.substring(6, text.length)}';
                            }
                          } else if (text.length > 2) {
                            formattedText =
                                '${text.substring(0, 2)}:${text.substring(2, text.length)}';
                          }
                          return TextEditingValue(
                            text: formattedText,
                            selection: TextSelection.collapsed(
                                offset: formattedText.length),
                          );
                        },
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Operating Hours are required';
                      }
                      final hoursRegex =
                          RegExp(r'^\d{2}:\d{2}\s-\s\d{2}:\d{2}$');
                      if (!hoursRegex.hasMatch(value)) {
                        return 'Enter valid operating hours (e.g., 09:00 - 23:00)';
                      }
                      return null;
                    },
                  ),
                  // Restaurant ID
                  Obx(() => TextFormField(
                        controller: restaurantIdController,
                        decoration: InputDecoration(
                          labelText: 'Restaurant ID',
                          errorText: isRestaurantIdDuplicate.value
                              ? 'Restaurant ID already in use'
                              : null,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Restaurant ID is required' : null,
                        onChanged: (value) =>
                            _checkDuplicateDebounced('restaurantId', value),
                      )),
                  // Has Tables
                  Obx(() => SwitchListTile(
                        title: const Text('Has Tables'),
                        value: hasTables.value,
                        onChanged: (value) => hasTables.value = value,
                      )),
                  // Number of Tables
                  Obx(() => hasTables.value
                      ? TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Number of Tables'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              tables.value = int.tryParse(value) ?? 0,
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 20),
                  // Register Button
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatPhoneNumber(String input) {
    input = input.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

    if (input.startsWith('02')) {
      if (input.length == 10) {
        return input.replaceFirstMapped(RegExp(r'^(\d{2})(\d{4})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      } else if (input.length == 9) {
        return input.replaceFirstMapped(RegExp(r'^(\d{2})(\d{3})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      }
    } else if (input.startsWith('010')) {
      if (input.length == 11) {
        return input.replaceFirstMapped(RegExp(r'^(\d{3})(\d{4})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      } else if (input.length == 10) {
        return input.replaceFirstMapped(RegExp(r'^(\d{3})(\d{3})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      }
    } else {
      if (input.length == 11) {
        return input.replaceFirstMapped(RegExp(r'^(\d{3})(\d{4})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      } else if (input.length == 10) {
        return input.replaceFirstMapped(RegExp(r'^(\d{3})(\d{3})(\d{4})$'),
            (m) => '${m[1]}-${m[2]}-${m[3]}');
      }
    }

    return input; // Return the unformatted input if it doesn't match known patterns
  }

  Future<void> _checkDuplicateDebounced(String field, String value) async {
    if (value.isNotEmpty) {
      bool isDuplicate = await controller.checkDuplicate(field, value);
      switch (field) {
        case 'email':
          isEmailDuplicate.value = isDuplicate;
          break;
        case 'businessNumber':
          isBusinessNumberDuplicate.value = isDuplicate;
          break;
        case 'restaurantId':
          isRestaurantIdDuplicate.value = isDuplicate;
          break;
      }
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate() &&
        !isEmailDuplicate.value &&
        !isRestaurantIdDuplicate.value &&
        !isBusinessNumberDuplicate.value) {
      try {
        // Remove hyphens before saving
        String rawPhoneNumber = phoneNumberController.text.replaceAll('-', '');
        String rawBusinessNumber =
            businessNumberController.text.replaceAll('-', '');

        await controller.register(
          email: emailController.text,
          password: passwordController.text,
          businessName: businessNameController.text,
          address: addressController.text,
          phoneNumber: rawPhoneNumber, // Unformatted phone number
          businessNumber: rawBusinessNumber, // Unformatted business number
          operatingHours: operatingHoursController.text,
          restaurantId: restaurantIdController.text,
          hasTables: hasTables.value,
          tables: tables.value,
        );

        // Navigate to admin page after successful registration and login
        await controller.login(
            restaurantIdController.text, passwordController.text);

        Get.snackbar('Success', 'Registration and login successful');
        Get.offAllNamed('/admin');
      } catch (e) {
        Get.snackbar('Error', 'Registration or login failed: ${e.toString()}');
      }
    }
  }
}
