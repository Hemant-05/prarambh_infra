import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/admin/data/models/lead_models.dart';

class ExcelHelper {
  static Future<bool> exportLeadsToExcel(List<dynamic> leads, {String prefix = 'Priority_Leads'}) async {
    try {
      // 1. Create Excel (No manual permission needed for temp directory + share_plus)
      var excel = Excel.createExcel();
      Sheet sheetObject = excel[prefix];
      excel.setDefaultSheet(prefix);

      // Define Headers
      List<String> headers = [
        'ID',
        'Client Name',
        'Client Number',
        'Advisor Code',
        'Source',
        'Age',
        'Occupation',
        'Category (A/B/C)',
        'Potential (Hot/Warm/Cold)',
        'Client Address',
        'Owns House',
        'Annual Income',
        'Decision Maker',
        'Is Priority',
        'Stage',
        'Property ID',
        'Call Outcome',
        'Reason',
        'Notes',
        'Reminder',
        'Meeting Point',
        'Comm. Attempts',
        'Created At',
        'Updated At'
      ];

      // Styling Headers
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
          horizontalAlign: HorizontalAlign.Center,
        );
      }

      // 3. Fill Data
      for (int i = 0; i < leads.length; i++) {
        final item = leads[i];
        List<CellValue> row;

        if (item is LeadModel) {
          row = [
            TextCellValue(item.id),
            TextCellValue(item.clientName),
            TextCellValue(item.clientNumber),
            TextCellValue(item.advisorCode),
            TextCellValue(item.source),
            TextCellValue(item.clientAge),
            TextCellValue(item.clientOccupation),
            TextCellValue(item.leadCategory),
            TextCellValue(item.leadPotential),
            TextCellValue(item.clientAddress),
            TextCellValue(item.ownsHouse),
            TextCellValue(item.annualIncome),
            TextCellValue(item.keyDecisionMaker ? 'Yes' : 'No'),
            TextCellValue(item.isPriority ? 'Yes' : 'No'),
            TextCellValue(item.stage),
            TextCellValue(item.propertyId == 0 ? '' : item.propertyId.toString()),
            TextCellValue(item.callOutCome),
            TextCellValue(item.reason),
            TextCellValue(item.notes),
            TextCellValue(item.reminder),
            TextCellValue(item.meetingPoint),
            TextCellValue(item.communicationAttempt.toString()),
            TextCellValue(item.createdAt),
            TextCellValue(item.updatedAt),
          ];
        } else {
          final lead = Map<String, dynamic>.from(item);
          row = [
            TextCellValue(lead['id']?.toString() ?? ''),
            TextCellValue(lead['client_name']?.toString() ?? ''),
            TextCellValue(lead['client_number']?.toString() ?? ''),
            TextCellValue(lead['advisor_code']?.toString() ?? ''),
            TextCellValue(lead['source']?.toString() ?? ''),
            TextCellValue(lead['client_age']?.toString() ?? ''),
            TextCellValue(lead['client_occupation']?.toString() ?? ''),
            TextCellValue(lead['lead_category']?.toString() ?? ''),
            TextCellValue(lead['lead_potential']?.toString() ?? ''),
            TextCellValue(lead['client_address']?.toString() ?? ''),
            TextCellValue(lead['owns_house']?.toString() ?? ''),
            TextCellValue(lead['annual_income']?.toString() ?? ''),
            TextCellValue(lead['key_decision_maker']?.toString() == '1' || lead['key_decision_maker'] == true ? 'Yes' : 'No'),
            TextCellValue(lead['is_priority']?.toString() == '1' || lead['is_priority'] == true ? 'Yes' : 'No'),
            TextCellValue(lead['stage']?.toString() ?? ''),
            TextCellValue(lead['property_id']?.toString() == '0' ? '' : lead['property_id']?.toString() ?? ''),
            TextCellValue(lead['call_outcome']?.toString() ?? ''),
            TextCellValue(lead['reason']?.toString() ?? ''),
            TextCellValue(lead['notes']?.toString() ?? ''),
            TextCellValue(lead['reminder']?.toString() ?? ''),
            TextCellValue(lead['meeting_point']?.toString() ?? ''),
            TextCellValue(lead['communication_attempt']?.toString() ?? '0'),
            TextCellValue(lead['created_at']?.toString() ?? ''),
            TextCellValue(lead['updated_at']?.toString() ?? ''),
          ];
        }

        for (int j = 0; j < row.length; j++) {
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = row[j];
        }
      }

      // 4. Save and Share
      String fileName = "${prefix}_${DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now())}.xlsx";
      
      // We save to a temporary directory for immediate sharing
      final directory = await getTemporaryDirectory();
      final String path = "${directory.path}/$fileName";
      final File file = File(path);
      
      final List<int>? bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        
        // Use Share Plus to let the user save it to their Files / Storage
        await Share.shareXFiles([XFile(path)], text: '$prefix Export');
        return true;
      }
      return false;
    } catch (e) {
      print('Excel Export Error: $e');
      return false;
    }
  }
}
