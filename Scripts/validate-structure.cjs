const fs = require('fs');
const path = require('path');
const xcode = require('xcode');
const YAML = require('yaml');
const root = path.resolve(__dirname,'..');
const project = xcode.project(path.join(root,'NoteVault.xcodeproj/project.pbxproj'));
project.parseSync();
const objects = project.hash.project.objects;
const refs = objects.PBXFileReference;
let swift = 0;
for(const [key,ref] of Object.entries(refs)) {
  if(key.endsWith('_comment')) continue;
  const value = String(ref.path).replace(/^"|"$/g,'');
  if(value.endsWith('.swift')) { if(!fs.existsSync(path.join(root,value))) throw new Error(`Missing ${value}`); swift++; }
}
const workflow=YAML.parse(fs.readFileSync(path.join(root,'.github/workflows/ios-build.yml'),'utf8'));
if(workflow.jobs.build['runs-on']!=='macos-15') throw new Error('Unexpected runner');
if(workflow.jobs.build.if!=='github.event.repository.private == false') throw new Error('Missing budget guard');
if(!('workflow_dispatch' in workflow.on)) throw new Error('Missing manual trigger');
if(workflow.jobs.build.steps.filter(s=>s.uses?.startsWith('actions/upload-artifact')).some(s=>s.with['retention-days']!==1)) throw new Error('Unexpected retention');
const allSources = Object.values(refs).filter(x=>typeof x==='object' && String(x.path).endsWith('.swift"')).map(x=>x.path);
console.log(`PASS: OpenStep Xcode project parsed; ${swift} Swift source references exist.`);
console.log('PASS: workflow YAML parsed; standard macOS runner, manual trigger, public-only budget guard and 1-day artifacts.');
console.log('NOT RUN: Swift compiler, XCTest, simulator, device signing or installation.');
