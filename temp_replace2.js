const fs = require('fs');
const file = 'lib/features/admin/presentation/screens/admin_deals_screen.dart';
let code = fs.readFileSync(file, 'utf8');

const replacements = [
  ['\"Deals Management\"', '\"BOOKING MANAGEMENT\"'],
  ['\"Deal Management\"', '\"BOOKING MANAGEMENT\"']
];

for (const [search, replace] of replacements) {
  code = code.split(search).join(replace);
}

fs.writeFileSync(file, code);
