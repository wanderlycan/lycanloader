const fs = require('fs');
const template = fs.readFileSync('bootstrap.ps1','utf8');
fs.writeFileSync('commands.js', '// Generated from bootstrap.ps1 by build.cjs.\nfunction makeCommands(url) {\n  const template = ' + JSON.stringify(template) + ';\n  return template.replace("__URL__", () => "\x27" + url.toString().replaceAll("\x27", "\x27\x27") + "\x27");\n}\n');
