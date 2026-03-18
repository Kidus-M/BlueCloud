import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _incidentTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _suspectNameController = TextEditingController();
  final _suspectRaceSexController = TextEditingController();
  final _suspectDOBController = TextEditingController();
  final _suspectVehicleController = TextEditingController();
  final _victimNameController = TextEditingController();
  final _victimRaceSexController = TextEditingController();
  final _victimDOBController = TextEditingController();
  final _victimInjuriesController = TextEditingController();
  final _propertyLossController = TextEditingController();
  final _csnPreparedByController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _synopsisController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedDistrict;
  String? _selectedArrestMade;
  String? _selectedWeapons;
  String? _selectedGangRelated;

  final List<String> _districts = [
    'District 1',
    'District 2',
    'District 3',
    'District 4',
    'District 5',
    'Central',
    'North',
    'South',
    'East',
    'West',
  ];

  final List<String> _weapons = [
    'None',
    'Handgun',
    'Rifle',
    'Shotgun',
    'Knife',
    'Blunt Object',
    'Other',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _incidentTypeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _suspectNameController.dispose();
    _suspectRaceSexController.dispose();
    _suspectDOBController.dispose();
    _suspectVehicleController.dispose();
    _victimNameController.dispose();
    _victimRaceSexController.dispose();
    _victimDOBController.dispose();
    _victimInjuriesController.dispose();
    _propertyLossController.dispose();
    _csnPreparedByController.dispose();
    _caseNumberController.dispose();
    _synopsisController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = DateFormat('MM/dd/yyyy').format(date);
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _timeController.text = time.format(context);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    final report = ReportModel(
      createdBy: authProvider.firebaseUser!.uid,
      createdByName: authProvider.userModel?.fullName ?? 'Unknown',
      incidentType: _incidentTypeController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      time: _timeController.text.trim(),
      district: _selectedDistrict ?? '',
      location: _locationController.text.trim(),
      arrestMade: _selectedArrestMade ?? 'No',
      suspectName: _suspectNameController.text.trim(),
      suspectRaceSex: _suspectRaceSexController.text.trim(),
      suspectDOB: _suspectDOBController.text.trim(),
      suspectVehicle: _suspectVehicleController.text.trim(),
      weapons: _selectedWeapons ?? 'None',
      victimName: _victimNameController.text.trim(),
      victimRaceSex: _victimRaceSexController.text.trim(),
      victimDOB: _victimDOBController.text.trim(),
      victimInjuriesStatus: _victimInjuriesController.text.trim(),
      propertyLossDamage: _propertyLossController.text.trim(),
      gangRelated: _selectedGangRelated ?? 'No',
      csnPreparedBy: _csnPreparedByController.text.trim(),
      caseNumber: _caseNumberController.text.trim(),
      synopsis: _synopsisController.text.trim(),
    );

    final success = await reportProvider.submitReport(report);

    if (success && mounted) {
      _clearForm();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 45,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Report Submitted!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your incident report has been submitted successfully and notifications have been sent.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _clearForm() {
    _incidentTypeController.clear();
    _dateController.clear();
    _timeController.clear();
    _locationController.clear();
    _suspectNameController.clear();
    _suspectRaceSexController.clear();
    _suspectDOBController.clear();
    _suspectVehicleController.clear();
    _victimNameController.clear();
    _victimRaceSexController.clear();
    _victimDOBController.clear();
    _victimInjuriesController.clear();
    _propertyLossController.clear();
    _csnPreparedByController.clear();
    _caseNumberController.clear();
    _synopsisController.clear();
    setState(() {
      _selectedDate = null;
      _selectedDistrict = null;
      _selectedArrestMade = null;
      _selectedWeapons = null;
      _selectedGangRelated = null;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(
              icon: Icons.description_rounded,
              title: 'INCIDENT REPORT',
              subtitle: 'Command Staff Notification',
            ),
            const SizedBox(height: 20),

            // Report Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incident Type
                  CustomTextField(
                    label: 'Incident Type *',
                    hint: 'e.g. Robbery, Assault, Homicide',
                    controller: _incidentTypeController,
                    prefixIcon: Icons.report_problem_rounded,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return null;
                    },
                  ),

                  // Date & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Date *',
                          hint: 'Select date',
                          controller: _dateController,
                          prefixIcon: Icons.calendar_today_rounded,
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Time *',
                          hint: 'Select time',
                          controller: _timeController,
                          prefixIcon: Icons.access_time_rounded,
                          readOnly: true,
                          onTap: _selectTime,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // District
                  CustomDropdown(
                    label: 'District *',
                    value: _selectedDistrict,
                    items: _districts,
                    prefixIcon: Icons.location_city_rounded,
                    onChanged: (v) => setState(() => _selectedDistrict = v),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return null;
                    },
                  ),

                  // Location
                  CustomTextField(
                    label: 'Location *',
                    hint: 'Enter incident location',
                    controller: _locationController,
                    prefixIcon: Icons.location_on_rounded,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      return null;
                    },
                  ),

                  // Arrest Made
                  CustomDropdown(
                    label: 'Arrest Made',
                    value: _selectedArrestMade,
                    items: const ['Yes', 'No'],
                    prefixIcon: Icons.gavel_rounded,
                    onChanged: (v) => setState(() => _selectedArrestMade = v),
                  ),

                  const SizedBox(height: 8),
                  _buildDividerWithTitle('SUSPECT INFORMATION'),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Suspect Name',
                    hint: 'Full name',
                    controller: _suspectNameController,
                    prefixIcon: Icons.person_rounded,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Race / Sex',
                          hint: 'e.g. W/M',
                          controller: _suspectRaceSexController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'DOB',
                          hint: 'MM/DD/YYYY',
                          controller: _suspectDOBController,
                        ),
                      ),
                    ],
                  ),

                  CustomTextField(
                    label: 'Suspect Vehicle',
                    hint: 'Vehicle description',
                    controller: _suspectVehicleController,
                    prefixIcon: Icons.directions_car_rounded,
                  ),

                  // Weapons
                  CustomDropdown(
                    label: 'Weapon(s)',
                    value: _selectedWeapons,
                    items: _weapons,
                    prefixIcon: Icons.warning_rounded,
                    onChanged: (v) => setState(() => _selectedWeapons = v),
                  ),

                  const SizedBox(height: 8),
                  _buildDividerWithTitle('VICTIM INFORMATION'),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Victim Name',
                    hint: 'Full name',
                    controller: _victimNameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Race / Sex',
                          hint: 'e.g. B/F',
                          controller: _victimRaceSexController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'DOB',
                          hint: 'MM/DD/YYYY',
                          controller: _victimDOBController,
                        ),
                      ),
                    ],
                  ),

                  CustomTextField(
                    label: "Victim's Injuries & Status",
                    hint: 'Describe injuries and current status',
                    controller: _victimInjuriesController,
                    prefixIcon: Icons.local_hospital_rounded,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 8),
                  _buildDividerWithTitle('ADDITIONAL DETAILS'),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Property Loss or Damage',
                    hint: 'Describe property loss/damage',
                    controller: _propertyLossController,
                    prefixIcon: Icons.business_rounded,
                    maxLines: 2,
                  ),

                  // Gang Related
                  CustomDropdown(
                    label: 'Gang Related',
                    value: _selectedGangRelated,
                    items: const ['Yes', 'No'],
                    prefixIcon: Icons.groups_rounded,
                    onChanged: (v) => setState(() => _selectedGangRelated = v),
                  ),

                  CustomTextField(
                    label: 'CSN Prepared By',
                    hint: 'Officer name',
                    controller: _csnPreparedByController,
                    prefixIcon: Icons.badge_rounded,
                  ),

                  CustomTextField(
                    label: 'Case Number',
                    hint: 'Case #',
                    controller: _caseNumberController,
                    prefixIcon: Icons.tag_rounded,
                  ),

                  const SizedBox(height: 8),
                  _buildDividerWithTitle('SYNOPSIS'),
                  const SizedBox(height: 12),

                  CustomTextField(
                    label: 'Synopsis *',
                    hint: 'Provide a detailed synopsis of the incident...',
                    controller: _synopsisController,
                    maxLines: 5,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Synopsis is required';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Consumer<ReportProvider>(
              builder: (context, reportProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: reportProvider.isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: reportProvider.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(AppColors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Submitting...',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'SUBMIT REPORT',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDividerWithTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.lightGrey,
          ),
        ),
      ],
    );
  }
}
