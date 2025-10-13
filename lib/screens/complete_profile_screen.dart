import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  String _phone = '';
  String _address = '';
  String _bloodGroup = '';
  String _profession = '';
  bool _isLoading = false;
  int _currentPage = 0;

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final dataToUpdate = {
      'phone': _phone,
      'address': _address,
      'bloodGroup': _bloodGroup,
      'profession': _profession,
    };

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateUserProfile(dataToUpdate);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return Container(
                    width: 40, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage >= index ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildStepOne(),
                    _buildStepTwo(),
                  ],
                ),
              ),

              if (_isLoading)
                const CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        ),
                        child: const Text('Back'),
                      ),
                    ElevatedButton(
                      onPressed: _currentPage == 1 ? _submitProfile : _nextPage,
                      child: Text(_currentPage == 1 ? 'Finish' : 'Next'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.isEmpty || v.length < 11 ? 'Enter a valid 11-digit phone number' : null,
            onSaved: (v) => _phone = v!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Enter your blood group' : null,
            onSaved: (v) => _bloodGroup = v!,
          ),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Address & Profession', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Current Address', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Enter your address' : null,
            onSaved: (v) => _address = v!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Profession', border: OutlineInputBorder()),
            validator: (v) => v == null || v.isEmpty ? 'Enter your profession' : null,
            onSaved: (v) => _profession = v!,
          ),
        ],
      ),
    );
  }
}