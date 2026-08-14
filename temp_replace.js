const fs = require('fs');
const file = 'lib/features/admin/presentation/screens/deal_management_screen.dart';
let code = fs.readFileSync(file, 'utf8');

const replacements = [
  ['\"Deal Configuration\"', '\"BOOKING CONFIGURATION\"'],
  ['Deal Configuration Saved Successfully!', 'Booking Configuration Saved Successfully!'],
  ['\"ACTION PLATE\"', '\"ACTION\"'],
  ['\"Client Profile & KYC\"', '\"CUSTOMER DETAIL & KYC\"'],
  ['\"Client Profile\"', '\"CUSTOMER DETAIL\"'],
  ['\"Property Specification\"', '\"PROPERTY DETAILS\"'],
  ['\"Commercial Architecture\"', '\"COMMERCIAL DETAILS\"'],
  ['\"Strategy Plan\"', '\"INSTALLMENT PLAN\"'],
  ['\"Installment Pulse\"', '\"INSTALLMENT COUNT\"'],
  ['\"Confirm Configuration\"', '\"CONFIRM BOOKING\"'],
  ['\"MODE\"', '\"MODE OF PAYMENT\"'],
  ['Deal Management', 'BOOKING MANAGEMENT'],
  ['\"Client\"', '\"CUSTOMER\"'],
  ['\"client\"', '\"customer\"']
];

for (const [search, replace] of replacements) {
  code = code.split(search).join(replace);
}

fs.writeFileSync(file, code);
