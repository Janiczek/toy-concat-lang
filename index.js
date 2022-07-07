import {Elm} from './elm.js';
import * as fs from 'fs';
const inputPath = 'example.prg';
const flags = {
  inputPath,
  inputContents: fs.readFileSync(inputPath, 'utf-8'),
  outputJsPath: 'example.js',
};
const app = Elm.Main.init({flags: flags});
app.ports.stderr.subscribe(str => process.stderr.write(str + '\n'));
app.ports.writeFileWithConfirmation.subscribe(({path,contents}) => {
  fs.writeFileSync(path,contents);
  console.log(`Written file ${path}.`);
});
