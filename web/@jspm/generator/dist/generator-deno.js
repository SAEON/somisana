import babel from '@babel/core';
import babelPresetTs from '@babel/preset-typescript';
import babelPluginSyntaxImportAssertions from '@babel/plugin-syntax-import-assertions';
import { createHash } from 'crypto';
import { realpath } from 'fs';
import { pathToFileURL } from 'url';
import { s as setCreateHash, a as setPathFns, b as setBabel, c as setBabel$1 } from './generator-711a2384.js';
export { G as Generator, d as analyzeHtml, e as clearCache, f as fetch, h as getPackageBase, g as getPackageConfig, l as lookup } from './generator-711a2384.js';
import 'sver';
import 'sver/convert-range.js';
import '#fetch';
import 'es-module-lexer/js';
import '@jspm/import-map';
import 'process';

setBabel(babel);
setBabel$1(babel, babelPresetTs, babelPluginSyntaxImportAssertions);
setCreateHash(createHash);
setPathFns(realpath, pathToFileURL);
