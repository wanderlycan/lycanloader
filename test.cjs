const fs = require('fs');
const vm = require('vm');
const assert = require('node:assert/strict');
const cp = require('child_process');
const context = vm.createContext({});
vm.runInContext(fs.readFileSync('commands.js','utf8'),context);
const html = fs.readFileSync('index.html','utf8');
for (const script of html.matchAll(/<script>([\s\S]*?)<\/script>/g)) new vm.Script(script[1]);
const urls = [
 'https://www.youtube.com/watch?v=test&list=example',
 "https://example.org/a'b?x=$('BAD')&y=`test`",
 'https://example.org/ação?q=um%20dois'
];
for (const input of urls) {
 const url = new URL(input);
 const result = context.makeCommands(url);
 assert(!result.includes('__URL__'));
 assert(result.includes("-- '" + url.toString().replaceAll("'", "''") + "'"));
 assert(result.indexOf('& $yt --ignore-config -U') < result.indexOf('Iniciando o download'));
 const parsed = cp.spawnSync('powershell', ['-NoProfile','-Command', '$source = [Console]::In.ReadToEnd(); $tokens=$null; $errors=$null; [System.Management.Automation.Language.Parser]::ParseInput($source,[ref]$tokens,[ref]$errors) | Out-Null; if ($errors.Count) { $errors | Out-String | Write-Output; exit 1 }'], {input:result,encoding:'utf8'});
 assert.equal(parsed.status,0,parsed.stdout + parsed.stderr);
}
assert.equal(context.makeCommands(new URL(urls[0])), fs.readFileSync('bootstrap.ps1','utf8').replace('__URL__', "'"+urls[0]+"'"));
console.log('OK: browser script syntax, template consistency, URL escaping and PowerShell parsing (3 URLs).');
