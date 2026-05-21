import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/team_models.dart';
import '../../../advisor/data/models/advisor_profile_model.dart';
import '../../../../core/theme/app_colors.dart';

class ShareProfileSheet extends StatefulWidget {
  final dynamic profile;
  const ShareProfileSheet({super.key, required this.profile});

  @override
  State<ShareProfileSheet> createState() => _ShareProfileSheetState();
}

class _ShareProfileSheetState extends State<ShareProfileSheet> {
  // Map to store selection state
  late Map<String, Map<String, bool>> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {
      'Personal Details': {
        'Name': true,
        'Advisor Code': true,
        'Phone': true,
        'Email': true,
        'Designation': true,
        'Father Name': false,
        'Date of Birth': false,
        'Gender': false,
        'Address': false,
        'Occupation': false,
        'Aadhaar Number': false,
        'PAN Number': false,
      },
      'Banking Details': {
        'Bank Name': false,
        'Account Number': false,
        'IFSC Code': false,
      },
      'Nominee Details': {
        'Nominee Name': false,
        'Relationship': false,
        'Nominee Phone': false,
      },
      'Leader Details': {
        'Leader Name': false,
        'Leader Code': false,
        'Leader Designation': false,
      },
      'Performance': {
        'Personal Sales': false,
        'Team Sales': false,
        'Team Size': false,
      },
    };
  }

  void _share() {
    final p = widget.profile;
    String name = 'N/A';
    if (p is BrokerProfileModel) {
      name = p.name;
    } else if (p is AdvisorProfileModel) {
      name = p.fullName;
    }
    
    StringBuffer sb = StringBuffer();
    sb.writeln('--- Advisor Profile: $name ---');

    _selection.forEach((category, fields) {
      bool hasSelected = fields.values.any((v) => v);
      if (hasSelected) {
        sb.writeln('\n[$category]');
        fields.forEach((field, isSelected) {
          if (isSelected) {
            String value = _getFieldValue(field, p);
            sb.writeln('$field: $value');
          }
        });
      }
    });

    Share.share(sb.toString(), subject: 'Profile Details of $name');
    Navigator.pop(context);
  }

  String _getFieldValue(String field, dynamic p) {
    if (p is BrokerProfileModel) {
      switch (field) {
        case 'Name': return p.name;
        case 'Advisor Code': return p.advisorCode;
        case 'Phone': return p.phone;
        case 'Email': return p.email;
        case 'Designation': return p.designation;
        case 'Father Name': return p.fatherName;
        case 'Date of Birth': return p.dateOfBirth;
        case 'Gender': return p.gender;
        case 'Address': return '${p.address}, ${p.city}, ${p.state} - ${p.pincode}';
        case 'Occupation': return p.occupation;
        case 'Aadhaar Number': return p.aadhaarNumber;
        case 'PAN Number': return p.panNumber;
        case 'Bank Name': return p.bankName;
        case 'Account Number': return p.accountNumber;
        case 'IFSC Code': return p.ifscCode;
        case 'Nominee Name': return p.nomineeName;
        case 'Relationship': return p.relationship;
        case 'Nominee Phone': return p.nomineePhone;
        case 'Leader Name': return p.leaderName ?? 'N/A';
        case 'Leader Code': return p.leaderCode ?? 'N/A';
        case 'Leader Designation': return p.leaderDesignation ?? 'N/A';
        case 'Personal Sales': return '₹${p.personalSales.toStringAsFixed(0)}';
        case 'Team Sales': return '₹${p.teamSales.toStringAsFixed(0)}';
        case 'Team Size': return '${p.myTeam.length} Members';
        default: return 'N/A';
      }
    } else if (p is AdvisorProfileModel) {
      switch (field) {
        case 'Name': return p.fullName;
        case 'Advisor Code': return p.advisorCode;
        case 'Phone': return p.phone;
        case 'Email': return p.email;
        case 'Designation': return p.designation;
        case 'Father Name': return p.fatherName;
        case 'Date of Birth': return p.dob;
        case 'Gender': return p.gender;
        case 'Address': return '${p.address}, ${p.city}, ${p.state} - ${p.pincode}';
        case 'Occupation': return p.occupation;
        case 'Aadhaar Number': return p.aadhaar;
        case 'PAN Number': return p.pan;
        case 'Bank Name': return p.bankName;
        case 'Account Number': return p.accNumber;
        case 'IFSC Code': return p.ifsc;
        case 'Nominee Name': return p.nomineeName;
        case 'Relationship': return p.relationship;
        case 'Nominee Phone': return p.nomineePhone;
        case 'Team Size': return 'N/A'; // Advisor model doesn't have team list here
        default: return 'N/A';
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = AppColors.getPrimaryBlue(context);
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Profile Details',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _share,
                  style: TextButton.styleFrom(
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Share Now',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _selection.entries.map((categoryEntry) {
                return ExpansionTile(
                  initiallyExpanded: categoryEntry.key == 'Personal Details',
                  leading: Icon(_getCategoryIcon(categoryEntry.key), color: primaryBlue),
                  title: Text(
                    categoryEntry.key,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                  children: categoryEntry.value.entries.map((fieldEntry) {
                    return CheckboxListTile(
                      activeColor: primaryBlue,
                      title: Text(
                        fieldEntry.key,
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                      value: fieldEntry.value,
                      onChanged: (val) {
                        setState(() {
                          _selection[categoryEntry.key]![fieldEntry.key] = val ?? false;
                        });
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal Details': return Icons.person_outline;
      case 'Banking Details': return Icons.account_balance_outlined;
      case 'Nominee Details': return Icons.group_outlined;
      case 'Leader Details': return Icons.stars_outlined;
      case 'Performance': return Icons.trending_up;
      default: return Icons.info_outline;
    }
  }
}
