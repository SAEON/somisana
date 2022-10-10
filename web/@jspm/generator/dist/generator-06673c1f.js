import sver, { SemverRange as SemverRange$2 } from 'sver';
import convertRange from 'sver/convert-range.js';
import { fetch as fetch$1, clearCache as clearCache$1 } from '#fetch';
import { parse } from 'es-module-lexer/js';
import { ImportMap, getScopeMatches, getMapMatch as getMapMatch$1 } from '@jspm/import-map';
import process$1 from 'process';

let babel$1;
function setBabel$1(_babel) {
    babel$1 = _babel;
}
async function createCjsAnalysis(imports, source, url) {
    if (!babel$1) ({ default: babel$1  } = await import('@babel/core'));
    const requires = new Set();
    const lazy = new Set();
    babel$1.transform(source, {
        ast: false,
        sourceMaps: false,
        inputSourceMap: false,
        babelrc: false,
        babelrcRoots: false,
        configFile: false,
        highlightCode: false,
        compact: false,
        sourceType: 'script',
        parserOpts: {
            allowReturnOutsideFunction: true,
            // plugins: stage3Syntax,
            errorRecovery: true
        },
        plugins: [
            ({ types: t  })=>{
                return {
                    visitor: {
                        Program (path, state) {
                            state.functionDepth = 0;
                        },
                        CallExpression (path, state) {
                            if (t.isIdentifier(path.node.callee, {
                                name: 'require'
                            }) || t.isIdentifier(path.node.callee.object, {
                                name: 'require'
                            }) && t.isIdentifier(path.node.callee.property, {
                                name: 'resolve'
                            }) || t.isMemberExpression(path.node.callee) && t.isIdentifier(path.node.callee.object, {
                                name: 'module'
                            }) && t.isIdentifier(path.node.callee.property, {
                                name: 'require'
                            })) {
                                const req = buildDynamicString$1(path.get('arguments.0').node, url);
                                requires.add(req);
                                if (state.functionDepth > 0) lazy.add(req);
                            }
                        },
                        Scope: {
                            enter (path, state) {
                                if (t.isFunction(path.scope.block)) state.functionDepth++;
                            },
                            exit (path, state) {
                                if (t.isFunction(path.scope.block)) state.functionDepth--;
                            }
                        }
                    }
                };
            }
        ]
    });
    return {
        deps: [
            ...requires
        ],
        dynamicDeps: imports.filter((impt)=>impt.n).map((impt)=>impt.n),
        cjsLazyDeps: [
            ...lazy
        ],
        size: source.length,
        format: 'commonjs'
    };
}
function buildDynamicString$1(node, fileName, isEsm = false, lastIsWildcard = false) {
    if (node.type === 'StringLiteral') {
        return node.value;
    }
    if (node.type === 'TemplateLiteral') {
        let str = '';
        for(let i = 0; i < node.quasis.length; i++){
            const quasiStr = node.quasis[i].value.cooked;
            if (quasiStr.length) {
                str += quasiStr;
                lastIsWildcard = false;
            }
            const nextNode = node.expressions[i];
            if (nextNode) {
                const nextStr = buildDynamicString$1(nextNode, fileName, isEsm, lastIsWildcard);
                if (nextStr.length) {
                    lastIsWildcard = nextStr.endsWith('*');
                    str += nextStr;
                }
            }
        }
        return str;
    }
    if (node.type === 'BinaryExpression' && node.operator === '+') {
        const leftResolved = buildDynamicString$1(node.left, fileName, isEsm, lastIsWildcard);
        if (leftResolved.length) lastIsWildcard = leftResolved.endsWith('*');
        const rightResolved = buildDynamicString$1(node.right, fileName, isEsm, lastIsWildcard);
        return leftResolved + rightResolved;
    }
    if (node.type === 'Identifier') {
        if (node.name === '__dirname') return '.';
        if (node.name === '__filename') return './' + fileName;
    }
    // TODO: proper expression support
    // new URL('...', import.meta.url).href | new URL('...', import.meta.url).toString() | new URL('...', import.meta.url).pathname
    // import.meta.X
    /*if (isEsm && node.type === 'MemberExpression' && node.object.type === 'MetaProperty' &&
      node.object.meta.type === 'Identifier' && node.object.meta.name === 'import' &&
      node.object.property.type === 'Identifier' && node.object.property.name === 'meta') {
    if (node.property.type === 'Identifier' && node.property.name === 'url') {
      return './' + fileName;
    }
  }*/ return lastIsWildcard ? '' : '*';
}

let babel, babelPresetTs, babelPluginImportAssertions;
function setBabel(_babel, _babelPresetTs, _babelPluginImportAssertions) {
    babel = _babel, babelPresetTs = _babelPresetTs, babelPluginImportAssertions = _babelPluginImportAssertions;
}
const globalConsole = globalThis.console;
const dummyConsole = {
    log () {},
    warn () {},
    memory () {},
    assert () {},
    clear () {},
    count () {},
    countReset () {},
    debug () {},
    dir () {},
    dirxml () {},
    error () {},
    exception () {},
    group () {},
    groupCollapsed () {},
    groupEnd () {},
    info () {},
    table () {},
    time () {},
    timeEnd () {},
    timeLog () {},
    timeStamp () {},
    trace () {}
};
async function createTsAnalysis(source, url) {
    if (!babel) [{ default: babel  }, { default: { default: babelPresetTs  }  }, { default: babelPluginImportAssertions  }] = await Promise.all([
        import('@babel/core'),
        import('@babel/preset-typescript'),
        import('@babel/plugin-syntax-import-assertions')
    ]);
    const imports = new Set();
    const dynamicImports = new Set();
    let importMeta = false;
    // @ts-ignore
    globalThis.console = dummyConsole;
    try {
        babel.transform(source, {
            filename: '/' + url,
            ast: false,
            sourceMaps: false,
            inputSourceMap: false,
            babelrc: false,
            babelrcRoots: false,
            configFile: false,
            highlightCode: false,
            compact: false,
            sourceType: 'module',
            parserOpts: {
                plugins: [
                    'jsx'
                ],
                errorRecovery: true
            },
            presets: [
                [
                    babelPresetTs,
                    {
                        onlyRemoveTypeImports: true
                    }
                ]
            ],
            plugins: [
                babelPluginImportAssertions,
                ({ types: t  })=>{
                    return {
                        visitor: {
                            ExportAllDeclaration (path) {
                                imports.add(path.node.source.value);
                            },
                            ExportNamedDeclaration (path) {
                                if (path.node.source) imports.add(path.node.source.value);
                            },
                            ImportDeclaration (path) {
                                imports.add(path.node.source.value);
                            },
                            Import (path) {
                                dynamicImports.add(buildDynamicString(path.parentPath.get('arguments.0').node, url, true));
                            },
                            MetaProperty (path) {
                                if (t.isIdentifier(path.node.meta, {
                                    name: 'import'
                                }) && t.isIdentifier(path.node.property, {
                                    name: 'meta'
                                })) {
                                    importMeta = true;
                                }
                            }
                        }
                    };
                }
            ]
        });
    } finally{
        globalThis.console = globalConsole;
    }
    return {
        deps: [
            ...imports
        ],
        dynamicDeps: [
            ...dynamicImports
        ],
        cjsLazyDeps: null,
        size: source.length,
        format: 'typescript'
    };
}
function buildDynamicString(node, fileName, isEsm = false, lastIsWildcard = false) {
    if (node.type === 'StringLiteral') {
        return node.value;
    }
    if (node.type === 'TemplateLiteral') {
        let str = '';
        for(let i = 0; i < node.quasis.length; i++){
            const quasiStr = node.quasis[i].value.cooked;
            if (quasiStr.length) {
                str += quasiStr;
                lastIsWildcard = false;
            }
            const nextNode = node.expressions[i];
            if (nextNode) {
                const nextStr = buildDynamicString(nextNode, fileName, isEsm, lastIsWildcard);
                if (nextStr.length) {
                    lastIsWildcard = nextStr.endsWith('*');
                    str += nextStr;
                }
            }
        }
        return str;
    }
    if (node.type === 'BinaryExpression' && node.operator === '+') {
        const leftResolved = buildDynamicString(node.left, fileName, isEsm, lastIsWildcard);
        if (leftResolved.length) lastIsWildcard = leftResolved.endsWith('*');
        const rightResolved = buildDynamicString(node.right, fileName, isEsm, lastIsWildcard);
        return leftResolved + rightResolved;
    }
    if (isEsm && node.type === 'Identifier') {
        if (node.name === '__dirname') return '.';
        if (node.name === '__filename') return './' + fileName;
    }
    // TODO: proper expression support
    // new URL('...', import.meta.url).href | new URL('...', import.meta.url).toString() | new URL('...', import.meta.url).pathname
    // import.meta.X
    /*if (isEsm && node.type === 'MemberExpression' && node.object.type === 'MetaProperty' &&
      node.object.meta.type === 'Identifier' && node.object.meta.name === 'import' &&
      node.object.property.type === 'Identifier' && node.object.property.name === 'meta') {
    if (node.property.type === 'Identifier' && node.property.name === 'url') {
      return './' + fileName;
    }
  }*/ return lastIsWildcard ? '' : '*';
}

class JspmError extends Error {
    constructor(msg, code){
        super(msg);
        this.jspmError = true;
        this.code = code;
    }
}
function throwInternalError(...args) {
    throw new Error('Internal Error' + (args.length ? ' ' + args.join(', ') : ''));
}

function isFetchProtocol(protocol) {
    return protocol === 'file:' || protocol === 'https:' || protocol === 'http:' || protocol === 'data:';
}
let baseUrl;
// @ts-ignore
if (typeof Deno !== 'undefined') {
    // @ts-ignore
    const denoCwd = Deno.cwd();
    baseUrl = new URL('file://' + (denoCwd[0] === '/' ? '' : '/') + denoCwd + '/');
} else if (typeof process !== 'undefined' && process.versions.node) {
    baseUrl = new URL('file://' + process.cwd() + '/');
} else if (typeof document !== 'undefined') {
    baseUrl = new URL(document.baseURI);
}
if (!baseUrl && typeof location !== 'undefined') {
    baseUrl = new URL(location.href);
}
baseUrl.search = baseUrl.hash = '';
function resolveUrl(url, mapUrl, rootUrl) {
    if (url.startsWith('/')) return rootUrl ? new URL('.' + url.slice(url[1] === '/' ? 1 : 0), rootUrl).href : url;
    return new URL(url, mapUrl).href;
}
function importedFrom(parentUrl) {
    if (!parentUrl) return '';
    return ` imported from ${parentUrl}`;
}
function matchesRoot(url, baseUrl) {
    return url.protocol === baseUrl.protocol && url.host === baseUrl.host && url.port === baseUrl.port && url.username === baseUrl.username && url.password === baseUrl.password;
}
function relativeUrl(url, baseUrl, absolute = false) {
    const href = url.href;
    let baseUrlHref = baseUrl.href;
    if (!baseUrlHref.endsWith('/')) baseUrlHref += '/';
    if (href.startsWith(baseUrlHref)) return (absolute ? '/' : './') + href.slice(baseUrlHref.length);
    if (!matchesRoot(url, baseUrl)) return url.href;
    if (absolute) return url.href;
    const baseUrlPath = baseUrl.pathname;
    const urlPath = url.pathname;
    const minLen = Math.min(baseUrlPath.length, urlPath.length);
    let sharedBaseIndex = -1;
    for(let i = 0; i < minLen; i++){
        if (baseUrlPath[i] !== urlPath[i]) break;
        if (urlPath[i] === '/') sharedBaseIndex = i;
    }
    return '../'.repeat(baseUrlPath.slice(sharedBaseIndex + 1).split('/').length - 1) + urlPath.slice(sharedBaseIndex + 1) + url.search + url.hash;
}
function isURL(specifier) {
    try {
        if (specifier[0] === '#') return false;
        new URL(specifier);
    } catch  {
        return false;
    }
    return true;
}
function isPlain(specifier) {
    return !isRelative(specifier) && !isURL(specifier);
}
function isRelative(specifier) {
    return specifier.startsWith('./') || specifier.startsWith('../') || specifier.startsWith('/');
}

const cdnUrl$4 = 'https://deno.land/x/';
const stdlibUrl = 'https://deno.land/std';
let denoStdVersion;
function resolveBuiltin$1(specifier, env) {
    if (specifier.startsWith('deno:')) {
        let name = specifier.slice(5);
        if (name.endsWith('.ts')) name = name.slice(0, -3);
        let alias = name, subpath = '.';
        const slashIndex = name.indexOf('/');
        if (slashIndex !== -1) {
            alias = name.slice(0, slashIndex);
            subpath = `./${name.slice(slashIndex + 1)}`;
        }
        return {
            alias,
            subpath,
            target: {
                pkgTarget: {
                    registry: 'deno',
                    name: 'std',
                    ranges: [
                        new SemverRange$2('*')
                    ],
                    unstable: true
                },
                installSubpath: `./${slashIndex === -1 ? name : name.slice(0, slashIndex)}`
            }
        };
    }
    if (specifier.startsWith('npm:')) return specifier;
}
function pkgToUrl$6(pkg) {
    if (pkg.registry === 'deno') return `${stdlibUrl}@${pkg.version}/`;
    if (pkg.registry === 'denoland') return `${cdnUrl$4}${pkg.name}@${vCache[pkg.name] ? 'v' : ''}${pkg.version}/`;
    throw new Error(`Deno provider does not support the ${pkg.registry} registry`);
}
async function getPackageConfig$2(pkgUrl) {
    if (pkgUrl.startsWith('https://deno.land/std@')) {
        return {
            exports: {
                './archive': './archive/mod.ts',
                './archive/*.ts': './archive/*.ts',
                './archive/*': './archive/*.ts',
                './async': './async/mod.ts',
                './async/*.ts': './async/*.ts',
                './async/*': './async/*.ts',
                './bytes': './bytes/mod.ts',
                './bytes/*.ts': './bytes/*.ts',
                './bytes/*': './bytes/*.ts',
                './collection': './collection/mod.ts',
                './collection/*.ts': './collection/*.ts',
                './collection/*': './collection/*.ts',
                './crypto': './crypto/mod.ts',
                './crypto/*.ts': './crypto/*.ts',
                './crypto/*': './crypto/*.ts',
                './datetime': './datetime/mod.ts',
                './datetime/*.ts': './datetime/*.ts',
                './datetime/*': './datetime/*.ts',
                './dotenv': './dotenv/mod.ts',
                './dotenv/*.ts': './dotenv/*.ts',
                './dotenv/*': './dotenv/*.ts',
                './encoding': './encoding/mod.ts',
                './encoding/*.ts': './encoding/*.ts',
                './encoding/*': './encoding/*.ts',
                './examples': './examples/mod.ts',
                './examples/*.ts': './examples/*.ts',
                './examples/*': './examples/*.ts',
                './flags': './flags/mod.ts',
                './flags/*.ts': './flags/*.ts',
                './flags/*': './flags/*.ts',
                './fmt': './fmt/mod.ts',
                './fmt/*.ts': './fmt/*.ts',
                './fmt/*': './fmt/*.ts',
                './fs': './fs/mod.ts',
                './fs/*.ts': './fs/*.ts',
                './fs/*': './fs/*.ts',
                './hash': './hash/mod.ts',
                './hash/*.ts': './hash/*.ts',
                './hash/*': './hash/*.ts',
                './http': './http/mod.ts',
                './http/*.ts': './http/*.ts',
                './http/*': './http/*.ts',
                './io': './io/mod.ts',
                './io/*.ts': './io/*.ts',
                './io/*': './io/*.ts',
                './log': './log/mod.ts',
                './log/*.ts': './log/*.ts',
                './log/*': './log/*.ts',
                './media_types': './media_types/mod.ts',
                './media_types/*.ts': './media_types/*.ts',
                './media_types/*': './media_types/*.ts',
                './node': './node/mod.ts',
                './node/*.ts': './node/*.ts',
                './node/*': './node/*.ts',
                './path': './path/mod.ts',
                './path/*.ts': './path/*.ts',
                './path/*': './path/*.ts',
                './permissions': './permissions/mod.ts',
                './permissions/*.ts': './permissions/*.ts',
                './permissions/*': './permissions/*.ts',
                './signal': './signal/mod.ts',
                './signal/*.ts': './signal/*.ts',
                './signal/*': './signal/*.ts',
                './streams': './streams/mod.ts',
                './streams/*.ts': './streams/*.ts',
                './streams/*': './streams/*.ts',
                './testing': './testing/mod.ts',
                './testing/*.ts': './testing/*.ts',
                './testing/*': './testing/*.ts',
                './textproto': './textproto/mod.ts',
                './textproto/*.ts': './textproto/*.ts',
                './textproto/*': './textproto/*.ts',
                './uuid': './uuid/mod.ts',
                './uuid/*.ts': './uuid/*.ts',
                './uuid/*': './uuid/*.ts',
                './version': './version.ts',
                './version.ts': './version.ts',
                './wasi': './wasi/mod.ts',
                './wasi/*.ts': './wasi/*.ts',
                './wasi/*': './wasi*.ts'
            }
        };
    }
    return null;
}
const vCache = {};
function parseUrlPkg$6(url) {
    let subpath = null;
    if (url.startsWith(stdlibUrl) && url[stdlibUrl.length] === '@') {
        const version = url.slice(stdlibUrl.length + 1, url.indexOf('/', stdlibUrl.length + 1));
        subpath = url.slice(stdlibUrl.length + version.length + 2);
        if (subpath.endsWith('/mod.ts')) subpath = subpath.slice(0, -7);
        else if (subpath.endsWith('.ts')) subpath = subpath.slice(0, -3);
        const name = subpath.indexOf('/') === -1 ? subpath : subpath.slice(0, subpath.indexOf('/'));
        return {
            pkg: {
                registry: 'deno',
                name: 'std',
                version
            },
            layer: 'default',
            subpath: `./${name}${subpath ? `./${subpath}/mod.ts` : ''}`
        };
    } else if (url.startsWith(cdnUrl$4)) {
        const path = url.slice(cdnUrl$4.length);
        const versionIndex = path.indexOf('@');
        if (versionIndex === -1) return;
        const sepIndex = path.indexOf('/', versionIndex);
        const name1 = path.slice(0, versionIndex);
        const version1 = path.slice(versionIndex + ((vCache[name1] = path[versionIndex + 1] === 'v') ? 2 : 1), sepIndex === -1 ? path.length : sepIndex);
        return {
            pkg: {
                registry: 'denoland',
                name: name1,
                version: version1
            },
            subpath: null,
            layer: 'default'
        };
    }
}
async function resolveLatestTarget$3(target, _layer, parentUrl) {
    let { registry , name , range  } = target;
    if (denoStdVersion && registry === 'deno') return {
        registry,
        name,
        version: denoStdVersion
    };
    if (range.isExact) return {
        registry,
        name,
        version: range.version.toString()
    };
    // convert all Denoland ranges into wildcards
    // since we don't have an actual semver lookup at the moment
    if (!range.isWildcard) range = new SemverRange$2(range.version.toString());
    const fetchOpts = {
        ...this.fetchOpts,
        headers: Object.assign({}, this.fetchOpts.headers || {}, {
            // For some reason, Deno provides different redirect behaviour for the server
            // Which requires us to use the text/html accept
            'accept': typeof document === 'undefined' ? 'text/html' : 'text/javascript'
        })
    };
    // "mod.ts" addition is necessary for the browser otherwise not resolving an exact module gives a CORS error
    const fetchUrl = registry === 'denoland' ? cdnUrl$4 + name + '/mod.ts' : stdlibUrl + '/version.ts';
    const res = await fetch$1(fetchUrl, fetchOpts);
    if (!res.ok) throw new Error(`Deno: Unable to lookup ${fetchUrl}`);
    const { version  } = parseUrlPkg$6(res.url).pkg;
    if (registry === 'deno') denoStdVersion = version;
    return {
        registry,
        name,
        version
    };
}

var deno = /*#__PURE__*/Object.freeze({
  __proto__: null,
  resolveBuiltin: resolveBuiltin$1,
  pkgToUrl: pkgToUrl$6,
  getPackageConfig: getPackageConfig$2,
  parseUrlPkg: parseUrlPkg$6,
  resolveLatestTarget: resolveLatestTarget$3
});

const { SemverRange: SemverRange$1  } = sver;
const supportedProtocols = [
    'https',
    'http',
    'data',
    'file',
    'ipfs'
];
async function parseUrlOrBuiltinTarget(resolver, targetStr, parentUrl) {
    const registryIndex = targetStr.indexOf(':');
    if (isRelative(targetStr) || registryIndex !== -1 && supportedProtocols.includes(targetStr.slice(0, registryIndex)) || builtinSchemes.has(targetStr.slice(0, registryIndex))) {
        let target;
        let alias;
        let subpath = '.';
        const maybeBuiltin = builtinSchemes.has(targetStr.slice(0, registryIndex)) && resolver.resolveBuiltin(targetStr);
        if (maybeBuiltin) {
            if (typeof maybeBuiltin === 'string') {
                throw new Error('How to install a string?');
            } else {
                ({ alias , subpath ='.' , target  } = maybeBuiltin);
            }
        } else {
            var ref;
            const subpathIndex = targetStr.indexOf('|');
            if (subpathIndex !== -1) {
                subpath = `./${targetStr.slice(subpathIndex + 1)}`;
                targetStr = targetStr.slice(0, subpathIndex);
            }
            target = {
                pkgTarget: new URL(targetStr + (targetStr.endsWith('/') ? '' : '/'), parentUrl || baseUrl),
                installSubpath: null
            };
            const pkgUrl = await resolver.getPackageBase(target.pkgTarget.href);
            alias = ((ref = pkgUrl ? await resolver.getPackageConfig(pkgUrl) : null) === null || ref === void 0 ? void 0 : ref.name) || target.pkgTarget.pathname.split('/').slice(0, -1).pop();
        }
        if (!alias) throw new JspmError(`Unable to determine an alias for target package ${targetStr}`);
        return {
            alias,
            target,
            subpath
        };
    }
}
async function toPackageTarget(resolver, targetStr, parentPkgUrl, defaultRegistry) {
    const urlTarget = await parseUrlOrBuiltinTarget(resolver, targetStr, parentPkgUrl);
    if (urlTarget) return urlTarget;
    const registryIndex = targetStr.indexOf(':');
    // TODO: package aliases support as per https://github.com/npm/rfcs/blob/latest/implemented/0001-package-aliases.md
    const versionOrScopeIndex = targetStr.indexOf('@');
    if (targetStr.indexOf(':') !== -1 && versionOrScopeIndex !== -1 && versionOrScopeIndex < registryIndex) throw new Error(`Package aliases not yet supported. PRs welcome.`);
    const pkg = parsePkg(registryIndex === -1 ? targetStr : targetStr.slice(registryIndex + 1));
    if (!pkg) throw new JspmError(`Invalid package name ${targetStr}`);
    let registry = null;
    if (registryIndex !== -1) registry = targetStr.slice(0, registryIndex);
    let alias = pkg.pkgName;
    const versionIndex = pkg.pkgName.indexOf('@', 1);
    if (versionIndex !== -1) alias = pkg.pkgName.slice(0, versionIndex);
    else alias = pkg.pkgName;
    return {
        target: newPackageTarget(pkg.pkgName, parentPkgUrl, registry || defaultRegistry),
        alias,
        subpath: pkg.subpath
    };
}
function newPackageTarget(target, parentPkgUrl, defaultRegistry, pkgName) {
    let registry, name, ranges;
    const registryIndex = target.indexOf(':');
    if (target.startsWith('./') || target.startsWith('../') || target.startsWith('/') || registryIndex === 1) return {
        pkgTarget: new URL(target, parentPkgUrl),
        installSubpath: null
    };
    registry = registryIndex < 1 ? defaultRegistry : target.slice(0, registryIndex);
    if (registry === 'file') return {
        pkgTarget: new URL(target.slice(registry.length + 1), parentPkgUrl),
        installSubpath: null
    };
    if (registry === 'https' || registry === 'http') return {
        pkgTarget: new URL(target),
        installSubpath: null
    };
    const versionIndex = target.lastIndexOf('@');
    let unstable = false;
    if (versionIndex > registryIndex + 1) {
        name = target.slice(registryIndex + 1, versionIndex);
        const version = target.slice(versionIndex + 1);
        ranges = pkgName || SemverRange$1.isValid(version) ? [
            new SemverRange$1(version)
        ] : version.split('||').map((v)=>convertRange(v));
        if (version === '') unstable = true;
    } else if (registryIndex === -1 && pkgName) {
        name = pkgName;
        ranges = SemverRange$1.isValid(target) ? [
            new SemverRange$1(target)
        ] : target.split('||').map((v)=>convertRange(v));
    } else {
        name = target.slice(registryIndex + 1);
        ranges = [
            new SemverRange$1('*')
        ];
    }
    if (registryIndex === -1 && name.indexOf('/') !== -1 && name[0] !== '@') registry = 'github';
    const targetNameLen = name.split('/').length;
    if (targetNameLen > 2 || targetNameLen === 1 && name[0] === '@') throw new JspmError(`Invalid package target ${target}`);
    return {
        pkgTarget: {
            registry,
            name,
            ranges,
            unstable
        },
        installSubpath: null
    };
}
function pkgToStr(pkg) {
    return `${pkg.registry ? pkg.registry + ':' : ''}${pkg.name}${pkg.version ? '@' + pkg.version : ''}`;
}
function validatePkgName(specifier) {
    const parsed = parsePkg(specifier);
    if (!parsed || parsed.subpath !== '.') throw new Error(`"${specifier}" is not a valid npm-style package name. Subpaths must be provided separately to the installation package name.`);
}
function parsePkg(specifier) {
    let sepIndex = specifier.indexOf('/');
    if (specifier[0] === '@') {
        if (sepIndex === -1) return;
        sepIndex = specifier.indexOf('/', sepIndex + 1);
    }
    // TODO: Node.js validations like percent encodng checks
    if (sepIndex === -1) return {
        pkgName: specifier,
        subpath: '.'
    };
    return {
        pkgName: specifier.slice(0, sepIndex),
        subpath: `.${specifier.slice(sepIndex)}`
    };
} // export function getPackageName (specifier: string, parentUrl: string) {
 //   let sepIndex = specifier.indexOf('/');
 //   if (specifier[0] === '@') {
 //     if (sepIndex === -1)
 //       throw new Error(`${specifier} is not an invalid scope name${importedFrom(parentUrl)}.`);
 //     sepIndex = specifier.indexOf('/', sepIndex + 1);
 //   }
 //   return sepIndex === -1 ? specifier : specifier.slice(0, sepIndex);
 // }

const cdnUrl$3 = 'https://ga.jspm.io/';
const systemCdnUrl = 'https://ga.system.jspm.io/';
const apiUrl = 'https://api.jspm.io/';
const BUILD_POLL_TIME = 5 * 60 * 1000;
const BUILD_POLL_INTERVAL = 5 * 1000;
function pkgToUrl$5(pkg, layer) {
    return `${layer === 'system' ? systemCdnUrl : cdnUrl$3}${pkgToStr(pkg)}/`;
}
const exactPkgRegEx$3 = /^(([a-z]+):)?((?:@[^/\\%@]+\/)?[^./\\%@][^/\\%@]*)@([^\/]+)(\/.*)?$/;
function parseUrlPkg$5(url) {
    let subpath = null;
    let layer;
    if (url.startsWith(cdnUrl$3)) layer = 'default';
    else if (url.startsWith(systemCdnUrl)) layer = 'system';
    else return;
    const [, , registry, name, version] = url.slice((layer === 'default' ? cdnUrl$3 : systemCdnUrl).length).match(exactPkgRegEx$3) || [];
    if (registry && name && version) {
        if (registry === 'npm' && name === '@jspm/core' && url.includes('/nodelibs/')) {
            subpath = `./nodelibs/${url.slice(url.indexOf('/nodelibs/') + 10).split('/')[1]}`;
            if (subpath && subpath.endsWith('.js')) subpath = subpath.slice(0, -3);
            else subpath = null;
        }
        return {
            pkg: {
                registry,
                name,
                version
            },
            layer,
            subpath
        };
    }
}
let resolveCache = {};
function clearResolveCache() {
    resolveCache = {};
}
async function checkBuildOrError(pkgUrl, fetchOpts) {
    const pjsonRes = await fetch$1(`${pkgUrl}package.json`, fetchOpts);
    if (pjsonRes.ok) return true;
    // no package.json! Check if there's a build error:
    const errLogRes = await fetch$1(`${pkgUrl}/_error.log`, fetchOpts);
    if (errLogRes.ok) {
        const errLog = await errLogRes.text();
        throw new JspmError(`Resolved dependency ${pkgUrl} with error:\n\n${errLog}\nPlease post an issue at jspm/project on GitHub, or by following the link below:\n\nhttps://github.com/jspm/project/issues/new?title=CDN%20build%20error%20for%20${encodeURIComponent(pkgUrl)}&body=_Reporting%20CDN%20Build%20Error._%0A%0A%3C!--%20%20No%20further%20description%20necessary,%20just%20click%20%22Submit%20new%20issue%22%20--%3E`);
    }
    console.error(`Unable to request ${pkgUrl}package.json - ${pjsonRes.status} ${pjsonRes.statusText || 'returned'}`);
    return false;
}
async function ensureBuild(pkg, fetchOpts) {
    if (await checkBuildOrError(pkgToUrl$5(pkg, 'default'), fetchOpts)) return;
    const fullName = `${pkg.name}@${pkg.version}`;
    // no package.json AND no build error -> post a build request
    // once the build request has been posted, try polling for up to 2 mins
    const buildRes = await fetch$1(`${apiUrl}build/${fullName}`, fetchOpts);
    if (!buildRes.ok && buildRes.status !== 403) {
        const err = (await buildRes.json()).error;
        throw new JspmError(`Unable to request the JSPM API for a build of ${fullName}, with error: ${err}.`);
    }
    // build requested -> poll on that
    let startTime = Date.now();
    while(true){
        await new Promise((resolve)=>setTimeout(resolve, BUILD_POLL_INTERVAL));
        if (await checkBuildOrError(pkgToUrl$5(pkg, 'default'), fetchOpts)) return;
        if (Date.now() - startTime >= BUILD_POLL_TIME) throw new JspmError(`Timed out waiting for the build of ${fullName} to be ready on the JSPM CDN. Try again later, or post a JSPM project issue if the issue persists.`);
    }
}
async function resolveLatestTarget$2(target, layer, parentUrl) {
    const { registry , name , range , unstable  } = target;
    // exact version optimization
    if (range.isExact && !range.version.tag) {
        const pkg = {
            registry,
            name,
            version: range.version.toString()
        };
        await ensureBuild(pkg, this.fetchOpts);
        return pkg;
    }
    const cache = resolveCache[target.registry + ':' + target.name] = resolveCache[target.registry + ':' + target.name] || {
        latest: null,
        majors: Object.create(null),
        minors: Object.create(null),
        tags: Object.create(null)
    };
    if (range.isWildcard || range.isExact && range.version.tag === 'latest') {
        let lookup = await (cache.latest || (cache.latest = lookupRange.call(this, registry, name, '', unstable, parentUrl)));
        // Deno wat?
        if (lookup instanceof Promise) lookup = await lookup;
        if (!lookup) return null;
        this.log('resolve', `${target.registry}:${target.name}@${range} -> WILDCARD ${lookup.version}${parentUrl ? ' [' + parentUrl + ']' : ''}`);
        await ensureBuild(lookup, this.fetchOpts);
        return lookup;
    }
    if (range.isExact && range.version.tag) {
        const tag = range.version.tag;
        let lookup1 = await (cache.tags[tag] || (cache.tags[tag] = lookupRange.call(this, registry, name, tag, unstable, layer, parentUrl)));
        // Deno wat?
        if (lookup1 instanceof Promise) lookup1 = await lookup1;
        if (!lookup1) return null;
        this.log('resolve', `${target.registry}:${target.name}@${range} -> TAG ${tag}${parentUrl ? ' [' + parentUrl + ']' : ''}`);
        await ensureBuild(lookup1, this.fetchOpts);
        return lookup1;
    }
    let stableFallback = false;
    if (range.isMajor) {
        const major = range.version.major;
        let lookup2 = await (cache.majors[major] || (cache.majors[major] = lookupRange.call(this, registry, name, major, unstable, layer, parentUrl)));
        // Deno wat?
        if (lookup2 instanceof Promise) lookup2 = await lookup2;
        if (!lookup2) return null;
        // if the latest major is actually a downgrade, use the latest minor version (fallthrough)
        // note this might miss later major prerelease versions, which should strictly be supported via a pkg@X@ unstable major lookup
        if (range.version.gt(lookup2.version)) {
            stableFallback = true;
        } else {
            this.log('resolve', `${target.registry}:${target.name}@${range} -> MAJOR ${lookup2.version}${parentUrl ? ' [' + parentUrl + ']' : ''}`);
            await ensureBuild(lookup2, this.fetchOpts);
            return lookup2;
        }
    }
    if (stableFallback || range.isStable) {
        const minor = `${range.version.major}.${range.version.minor}`;
        let lookup3 = await (cache.minors[minor] || (cache.minors[minor] = lookupRange.call(this, registry, name, minor, unstable, layer, parentUrl)));
        // in theory a similar downgrade to the above can happen for stable prerelease ranges ~1.2.3-pre being downgraded to 1.2.2
        // this will be solved by the pkg@X.Y@ unstable minor lookup
        // Deno wat?
        if (lookup3 instanceof Promise) lookup3 = await lookup3;
        if (!lookup3) return null;
        this.log('resolve', `${target.registry}:${target.name}@${range} -> MINOR ${lookup3.version}${parentUrl ? ' [' + parentUrl + ']' : ''}`);
        await ensureBuild(lookup3, this.fetchOpts);
        return lookup3;
    }
    return null;
}
function pkgToLookupUrl(pkg, edge = false) {
    return `${cdnUrl$3}${pkg.registry}:${pkg.name}${pkg.version ? '@' + pkg.version : edge ? '@' : ''}`;
}
async function lookupRange(registry, name, range, unstable, parentUrl) {
    const res = await fetch$1(pkgToLookupUrl({
        registry,
        name,
        version: range
    }, unstable), this.fetchOpts);
    switch(res.status){
        case 304:
        case 200:
            return {
                registry,
                name,
                version: (await res.text()).trim()
            };
        case 404:
            return null;
        default:
            throw new JspmError(`Invalid status code ${res.status} looking up "${registry}:${name}" - ${res.statusText}${importedFrom(parentUrl)}`);
    }
}

var jspm = /*#__PURE__*/Object.freeze({
  __proto__: null,
  pkgToUrl: pkgToUrl$5,
  parseUrlPkg: parseUrlPkg$5,
  clearResolveCache: clearResolveCache,
  resolveLatestTarget: resolveLatestTarget$2
});

const cdnUrl$2 = 'https://cdn.skypack.dev/';
function pkgToUrl$4(pkg) {
    return `${cdnUrl$2}${pkg.name}@${pkg.version}/`;
}
const exactPkgRegEx$2 = /^((?:@[^/\\%@]+\/)?[^./\\%@][^/\\%@]*)@([^\/]+)(\/.*)?$/;
function parseUrlPkg$4(url) {
    if (!url.startsWith(cdnUrl$2)) return;
    const [, name, version] = url.slice(cdnUrl$2.length).match(exactPkgRegEx$2) || [];
    if (!name || !version) return;
    return {
        registry: 'npm',
        name,
        version
    };
}

var skypack = /*#__PURE__*/Object.freeze({
  __proto__: null,
  pkgToUrl: pkgToUrl$4,
  parseUrlPkg: parseUrlPkg$4,
  resolveLatestTarget: resolveLatestTarget$2
});

const cdnUrl$1 = 'https://cdn.jsdelivr.net/';
function pkgToUrl$3(pkg) {
    return `${cdnUrl$1}${pkg.registry}/${pkg.name}@${pkg.version}/`;
}
const exactPkgRegEx$1 = /^([^\/]+)\/((?:@[^/\\%@]+\/)?[^./\\%@][^/\\%@]*)@([^\/]+)(\/.*)?$/;
function parseUrlPkg$3(url) {
    if (!url.startsWith(cdnUrl$1)) return;
    const [, registry, name, version] = url.slice(cdnUrl$1.length).match(exactPkgRegEx$1) || [];
    return {
        registry,
        name,
        version
    };
}

var jsdelivr = /*#__PURE__*/Object.freeze({
  __proto__: null,
  pkgToUrl: pkgToUrl$3,
  parseUrlPkg: parseUrlPkg$3,
  resolveLatestTarget: resolveLatestTarget$2
});

const cdnUrl = 'https://unpkg.com/';
function pkgToUrl$2(pkg) {
    return `${cdnUrl}${pkg.name}@${pkg.version}/`;
}
const exactPkgRegEx = /^((?:@[^/\\%@]+\/)?[^./\\%@][^/\\%@]*)@([^\/]+)(\/.*)?$/;
function parseUrlPkg$2(url) {
    if (!url.startsWith(cdnUrl)) return;
    const [, name, version] = url.slice(cdnUrl.length).match(exactPkgRegEx) || [];
    return {
        registry: 'npm',
        name,
        version
    };
}

var unpkg = /*#__PURE__*/Object.freeze({
  __proto__: null,
  pkgToUrl: pkgToUrl$2,
  parseUrlPkg: parseUrlPkg$2,
  resolveLatestTarget: resolveLatestTarget$2
});

// @ts-ignore
function pkgToUrl$1(pkg) {
    return `${new URL(pkg.version + pkg.name).href}/`;
}
function parseUrlPkg$1(url) {
    const nodeModulesIndex = url.lastIndexOf('/node_modules/');
    if (nodeModulesIndex === -1) return undefined;
    const version = url.slice(0, nodeModulesIndex + 14);
    const pkgParts = url.slice(nodeModulesIndex + 14).split('/');
    const name = pkgParts[0][0] === '@' ? pkgParts[0] + '/' + pkgParts[1] : pkgParts[0];
    return {
        registry: 'node_modules',
        name,
        version
    };
}
async function dirExists(url, parentUrl) {
    const res = await fetch$1(url, this.fetchOpts);
    switch(res.status){
        case 304:
        case 200:
            return true;
        case 404:
            return false;
        default:
            throw new JspmError(`Invalid status code ${res.status} looking up "${url}" - ${res.statusText}${importedFrom(parentUrl)}`);
    }
}
async function resolveLatestTarget$1(target, _layer, parentUrl) {
    let curUrl = new URL(`node_modules/${target.name}`, parentUrl);
    const rootUrl = new URL(`/node_modules/${target.name}`, parentUrl).href;
    while(!await dirExists.call(this, curUrl)){
        if (curUrl.href === rootUrl) return null;
        curUrl = new URL(`../../${target.name.indexOf('/') === -1 ? '' : '../'}node_modules/${target.name}`, curUrl);
    }
    return {
        registry: 'node_modules',
        name: target.name,
        version: curUrl.href.slice(0, -target.name.length)
    };
}

var nodemodules = /*#__PURE__*/Object.freeze({
  __proto__: null,
  pkgToUrl: pkgToUrl$1,
  parseUrlPkg: parseUrlPkg$1,
  resolveLatestTarget: resolveLatestTarget$1
});

const nodeBuiltinSet = new Set([
    '_http_agent',
    '_http_client',
    '_http_common',
    '_http_incoming',
    '_http_outgoing',
    '_http_server',
    '_stream_duplex',
    '_stream_passthrough',
    '_stream_readable',
    '_stream_transform',
    '_stream_wrap',
    '_stream_writable',
    '_tls_common',
    '_tls_wrap',
    'assert',
    'assert/strict',
    'async_hooks',
    'buffer',
    'child_process',
    'cluster',
    'console',
    'constants',
    'crypto',
    'dgram',
    'diagnostics_channel',
    'dns',
    'dns/promises',
    'domain',
    'events',
    'fs',
    'fs/promises',
    'http',
    'http2',
    'https',
    'inspector',
    'module',
    'net',
    'os',
    'path',
    'path/posix',
    'path/win32',
    'perf_hooks',
    'process',
    'punycode',
    'querystring',
    'readline',
    'repl',
    'stream',
    'stream/promises',
    'string_decoder',
    'sys',
    'timers',
    'timers/promises',
    'tls',
    'trace_events',
    'tty',
    'url',
    'util',
    'util/types',
    'v8',
    'vm',
    'wasi',
    'worker_threads',
    'zlib'
]);
function pkgToUrl(pkg, layer) {
    if (pkg.registry !== 'node') return pkgToUrl$5(pkg, layer);
    return `node:${pkg.name}/`;
}
function resolveBuiltin(specifier, env) {
    const builtin = specifier.startsWith('node:') ? specifier.slice(5) : nodeBuiltinSet.has(specifier) ? specifier : null;
    if (!builtin) return;
    if (env.includes('deno')) return {
        target: {
            pkgTarget: {
                registry: 'deno',
                name: 'std',
                ranges: [
                    new SemverRange$2('*')
                ],
                unstable: true
            },
            installSubpath: `./node/${builtin}`
        },
        alias: builtin
    };
    if (env.includes('node')) return `node:${builtin}`;
    return {
        target: {
            pkgTarget: {
                registry: 'npm',
                name: '@jspm/core',
                ranges: [
                    new SemverRange$2('*')
                ],
                unstable: true
            },
            installSubpath: `./nodelibs/${builtin}`
        },
        alias: builtin
    };
}
// Special "." export means a file package (not a folder package)
async function getPackageConfig$1() {
    return {
        exports: {
            ".": "."
        }
    };
}
async function resolveLatestTarget(target, layer, parentUrl) {
    if (target.registry !== 'npm' || target.name !== '@jspm/core') return null;
    return resolveLatestTarget$2.call(this, {
        registry: 'npm',
        name: '@jspm/core',
        range: new SemverRange$2('*'),
        unstable: true
    }, layer, parentUrl);
}
// export function parsePkg (pkg: string): { pkg: ExactPackage, subpath: null | `.${string}` } {
// }
function parseUrlPkg(url) {
    if (!url.startsWith('node:')) return;
    let name = url.slice(5);
    if (name.endsWith('/')) name = name.slice(0, -1);
    return {
        registry: 'node',
        name,
        version: ''
    };
}

var node = /*#__PURE__*/Object.freeze({
  __proto__: null,
  nodeBuiltinSet: nodeBuiltinSet,
  pkgToUrl: pkgToUrl,
  resolveBuiltin: resolveBuiltin,
  getPackageConfig: getPackageConfig$1,
  resolveLatestTarget: resolveLatestTarget,
  parseUrlPkg: parseUrlPkg
});

const defaultProviders = {
    deno,
    jsdelivr,
    jspm,
    node,
    nodemodules,
    skypack,
    unpkg
};
function getProvider(name, providers = defaultProviders) {
    const provider = providers[name];
    if (provider) return provider;
    throw new Error('No ' + name + ' provider is defined.');
}
const registryProviders = {
    'denoland:': 'deno',
    'deno:': 'deno'
};
const mappableSchemes = new Set([
    'npm',
    'deno',
    'node'
]);
const builtinSchemes = new Set([
    'node',
    'deno'
]);

function createEsmAnalysis(imports, source, url) {
    if (!imports.length && registerRegEx.test(source)) return createSystemAnalysis(source, imports, url);
    const deps = [];
    const dynamicDeps = [];
    for (const impt of imports){
        if (impt.d === -1) {
            if (!deps.includes(impt.n)) deps.push(impt.n);
            continue;
        }
        // dynamic import -> deoptimize trace all dependencies (and all their exports)
        if (impt.d >= 0) {
            if (impt.n) {
                try {
                    dynamicDeps.push(impt.n);
                } catch (e) {
                    console.warn(`TODO: Dynamic import custom expression tracing in ${url} for:\n\n${source.slice(impt.ss, impt.se)}\n`);
                }
            }
        }
    }
    const size = source.length;
    return {
        deps,
        dynamicDeps,
        cjsLazyDeps: null,
        size,
        format: 'esm'
    };
}
const registerRegEx = /^\s*(\/\*[^\*]*(\*(?!\/)[^\*]*)*\*\/|\s*\/\/[^\n]*)*\s*System\s*\.\s*register\s*\(\s*(\[[^\]]*\])\s*,\s*\(?function\s*\(\s*([^\),\s]+\s*(,\s*([^\),\s]+)\s*)?\s*)?\)/;
function createSystemAnalysis(source, imports, url) {
    const [, , , rawDeps, , , contextId] = source.match(registerRegEx) || [];
    if (!rawDeps) return createEsmAnalysis(imports, source, url);
    const deps = JSON.parse(rawDeps.replace(/'/g, '"'));
    const dynamicDeps = [];
    if (contextId) {
        const dynamicImport = `${contextId}.import(`;
        let i = -1;
        while((i = source.indexOf(dynamicImport, i + 1)) !== -1){
            const importStart = i + dynamicImport.length + 1;
            const quote = source[i + dynamicImport.length];
            if (quote === '"' || quote === '\'') {
                const importEnd = source.indexOf(quote, i + dynamicImport.length + 1);
                if (importEnd !== -1) {
                    try {
                        dynamicDeps.push(JSON.parse('"' + source.slice(importStart, importEnd) + '"'));
                        continue;
                    } catch (e) {}
                }
            }
            console.warn('TODO: Dynamic import custom expression tracing.');
        }
    }
    const size = source.length;
    return {
        deps,
        dynamicDeps,
        cjsLazyDeps: null,
        size,
        format: 'system'
    };
}

let realpath, pathToFileURL;
function setPathFns(_realpath, _pathToFileURL) {
    realpath = _realpath, pathToFileURL = _pathToFileURL;
}
function isBuiltinScheme(specifier) {
    if (specifier.indexOf(':') === -1) return false;
    return builtinSchemes.has(specifier.slice(0, specifier.indexOf(':')));
}
function isMappableScheme(specifier) {
    if (specifier.indexOf(':') === -1) return false;
    return mappableSchemes.has(specifier.slice(0, specifier.indexOf(':')));
}
class Resolver {
    addCustomProvider(name, provider) {
        if (!provider.pkgToUrl) throw new Error('Custom provider "' + name + '" must define a "pkgToUrl" method.');
        if (!provider.parseUrlPkg) throw new Error('Custom provider "' + name + '" must define a "parseUrlPkg" method.');
        if (!provider.resolveLatestTarget) throw new Error('Custom provider "' + name + '" must define a "resolveLatestTarget" method.');
        this.providers = Object.assign({}, this.providers, {
            [name]: provider
        });
    }
    parseUrlPkg(url) {
        for (const provider of Object.keys(this.providers)){
            const providerInstance = this.providers[provider];
            const result = providerInstance.parseUrlPkg.call(this, url);
            if (result) return {
                pkg: 'pkg' in result ? result.pkg : result,
                source: {
                    provider,
                    layer: 'layer' in result ? result.layer : 'default'
                },
                subpath: 'subpath' in result ? result.subpath : null
            };
        }
        return null;
    }
    pkgToUrl(pkg, { provider , layer  }) {
        return getProvider(provider, this.providers).pkgToUrl.call(this, pkg, layer);
    }
    resolveBuiltin(specifier) {
        for (const provider of Object.values(this.providers)){
            if (!provider.resolveBuiltin) continue;
            const builtin = provider.resolveBuiltin.call(this, specifier, this.env);
            if (builtin) return builtin;
        }
    }
    async getPackageBase(url) {
        const pkg = this.parseUrlPkg(url);
        if (pkg) return this.pkgToUrl(pkg.pkg, pkg.source);
        let testUrl;
        try {
            testUrl = new URL('./', url);
        } catch  {
            return url;
        }
        const rootUrl = new URL('/', testUrl).href;
        do {
            let responseUrl;
            if (responseUrl = await this.checkPjson(testUrl.href)) return new URL('.', responseUrl).href;
            // No package base -> use directory itself
            if (testUrl.href === rootUrl) return new URL('./', url).href;
        }while (testUrl = new URL('../', testUrl))
    }
    // TODO split this into getPackageDependencyConfig and getPackageResolutionConfig
    // since "dependencies" come from package base, while "imports" come from local pjson
    async getPackageConfig(pkgUrl) {
        if (!pkgUrl.startsWith('file:') && !pkgUrl.startsWith('http:') && !pkgUrl.startsWith('https:') && !pkgUrl.startsWith('ipfs:') && !pkgUrl.startsWith('node:')) return null;
        if (!pkgUrl.endsWith('/')) throw new Error(`Internal Error: Package URL must end in "/". Got ${pkgUrl}`);
        let cached = this.pcfgs[pkgUrl];
        if (cached) return cached;
        if (!this.pcfgPromises[pkgUrl]) this.pcfgPromises[pkgUrl] = (async ()=>{
            var ref;
            const parsed = this.parseUrlPkg(pkgUrl);
            if (parsed) {
                var ref1;
                const pcfg = await ((ref1 = getProvider(parsed.source.provider, this.providers).getPackageConfig) === null || ref1 === void 0 ? void 0 : ref1.call(this, pkgUrl));
                if (pcfg !== undefined) {
                    this.pcfgs[pkgUrl] = pcfg;
                    return;
                }
            }
            const res = await fetch$1(`${pkgUrl}package.json`, this.fetchOpts);
            switch(res.status){
                case 200:
                case 304:
                    break;
                case 400:
                case 401:
                case 403:
                case 404:
                case 406:
                    this.pcfgs[pkgUrl] = null;
                    return;
                default:
                    throw new JspmError(`Invalid status code ${res.status} reading package config for ${pkgUrl}. ${res.statusText}`);
            }
            if (res.headers && !((ref = res.headers.get('Content-Type')) === null || ref === void 0 ? void 0 : ref.match(/^application\/json(;|$)/))) {
                this.pcfgs[pkgUrl] = null;
            } else try {
                this.pcfgs[pkgUrl] = await res.json();
            } catch (e) {
                this.pcfgs[pkgUrl] = null;
            }
        })();
        await this.pcfgPromises[pkgUrl];
        return this.pcfgs[pkgUrl];
    }
    async getDepList(pkgUrl, dev = false) {
        const pjson = await this.getPackageConfig(pkgUrl);
        if (!pjson) return [];
        return [
            ...new Set([
                Object.keys(pjson.dependencies || {}),
                Object.keys(dev && pjson.devDependencies || {}),
                Object.keys(pjson.peerDependencies || {}),
                Object.keys(pjson.optionalDependencies || {}),
                Object.keys(pjson.imports || {})
            ].flat())
        ];
    }
    async checkPjson(url) {
        if (await this.getPackageConfig(url) === null) return false;
        return url;
    }
    async exists(resolvedUrl) {
        const res = await fetch$1(resolvedUrl, this.fetchOpts);
        switch(res.status){
            case 200:
            case 304:
                return true;
            case 400:
            case 401:
            case 403:
            case 404:
            case 406:
                return false;
            default:
                throw new JspmError(`Invalid status code ${res.status} loading ${resolvedUrl}. ${res.statusText}`);
        }
    }
    async resolveLatestTarget(target, { provider , layer  }, parentUrl) {
        // find the range to resolve latest
        let range;
        for (const possibleRange of target.ranges.sort(target.ranges[0].constructor.compare)){
            if (!range) {
                range = possibleRange;
            } else if (possibleRange.gt(range) && !range.contains(possibleRange)) {
                range = possibleRange;
            }
        }
        const latestTarget = {
            registry: target.registry,
            name: target.name,
            range,
            unstable: target.unstable
        };
        const pkg = await getProvider(provider, this.providers).resolveLatestTarget.call(this, latestTarget, layer, parentUrl);
        if (pkg) return pkg;
        throw new JspmError(`Unable to resolve package ${latestTarget.registry}:${latestTarget.name} to "${latestTarget.range}"${importedFrom(parentUrl)}`);
    }
    async wasCommonJS(url) {
        var ref;
        // TODO: make this a provider hook
        const pkgUrl = await this.getPackageBase(url);
        if (!pkgUrl) return false;
        const pcfg = await this.getPackageConfig(pkgUrl);
        if (!pcfg) return false;
        const subpath = './' + url.slice(pkgUrl.length);
        return (pcfg === null || pcfg === void 0 ? void 0 : (ref = pcfg.exports) === null || ref === void 0 ? void 0 : ref[subpath + '!cjs']) ? true : false;
    }
    async realPath(url) {
        if (!url.startsWith('file:') || this.preserveSymlinks) return url;
        let encodedColon = false;
        url = url.replace(/%3a/i, ()=>{
            encodedColon = true;
            return ':';
        });
        if (!realpath) {
            [{ realpath  }, { pathToFileURL  }] = await Promise.all([
                import('fs'),
                import('url')
            ]);
        }
        const outUrl = pathToFileURL(await new Promise((resolve, reject)=>realpath(new URL(url), (err, result)=>err ? reject(err) : resolve(result)))).href;
        if (encodedColon) return 'file:' + outUrl.slice(5).replace(':', '%3a');
        return outUrl;
    }
    async finalizeResolve(url, parentIsCjs, installer, pkgUrl) {
        if (parentIsCjs && url.endsWith('/')) url = url.slice(0, -1);
        // Only CJS modules do extension searching for relative resolved paths
        if (parentIsCjs) url = await (async ()=>{
            // subfolder checks before file checks because of fetch
            if (await this.exists(url + '/package.json')) {
                const pcfg = await this.getPackageConfig(url) || {};
                if (this.env.includes('browser') && typeof pcfg.browser === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.browser, new URL(url)), parentIsCjs, installer, pkgUrl);
                if (this.env.includes('module') && typeof pcfg.module === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.module, new URL(url)), parentIsCjs, installer, pkgUrl);
                if (typeof pcfg.main === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.main, new URL(url)), parentIsCjs, installer, pkgUrl);
                return this.finalizeResolve(await legacyMainResolve.call(this, null, new URL(url)), parentIsCjs, installer, pkgUrl);
            }
            if (await this.exists(url + '/index.js')) return url + '/index.js';
            if (await this.exists(url + '/index.json')) return url + '/index.json';
            if (await this.exists(url + '/index.node')) return url + '/index.node';
            if (await this.exists(url)) return url;
            if (await this.exists(url + '.js')) return url + '.js';
            if (await this.exists(url + '.json')) return url + '.json';
            if (await this.exists(url + '.node')) return url + '.node';
            return url;
        })();
        // Only browser maps apply to relative resolved paths
        if (this.env.includes('browser')) {
            pkgUrl = pkgUrl || await this.getPackageBase(url);
            if (url.startsWith(pkgUrl)) {
                const pcfg = await this.getPackageConfig(pkgUrl);
                if (pcfg && typeof pcfg.browser === 'object' && pcfg.browser !== null) {
                    const subpath = './' + url.slice(pkgUrl.length);
                    if (pcfg.browser[subpath]) {
                        const target = pcfg.browser[subpath];
                        if (target === false) throw new Error(`TODO: Empty browser map for ${subpath} in ${url}`);
                        if (!target.startsWith('./')) throw new Error(`TODO: External browser map for ${subpath} to ${target} in ${url}`);
                        // for browser mappings to the same module, avoid a loop
                        if (pkgUrl + target.slice(2) === url) return url;
                        return await this.finalizeResolve(pkgUrl + target.slice(2), parentIsCjs, installer, pkgUrl);
                    }
                }
            }
        }
        // // Node.js core resolutions
        // if (installer && url.startsWith('node:')) {
        //   const subpath: `./${string}` = `./nodelibs/${url.slice(5)}`;
        //   const { installUrl } = await installer.installTarget(url.slice(5), installer.stdlibTarget, subpath, 'new', pkgUrl, pkgUrl);
        //   return this.finalizeResolve(await this.resolveExport(installUrl, subpath, env, parentIsCjs, url, installer, new URL(pkgUrl)), parentIsCjs, env, installer, installUrl);
        // }
        return url;
    }
    // reverse exports resolution
    // returns _a_ possible export which resolves to the given package URL and subpath
    // also handles "imports"
    async getExportResolution(pkgUrl, subpath, originalSpecifier) {
        const pcfg = await this.getPackageConfig(pkgUrl) || {};
        if (originalSpecifier[0] === '#') {
            if (pcfg.imports === undefined || pcfg.imports === null) return null;
            const match = getMapMatch(originalSpecifier, pcfg.imports);
            if (!match) return null;
            const targets = enumeratePackageTargets(pcfg.imports[match]);
            for (const curTarget of targets){
                try {
                    if (await this.finalizeResolve(curTarget, false, null, pkgUrl) === pkgUrl + subpath.slice(2)) {
                        return '.';
                    }
                } catch  {}
            }
            return null;
        }
        if (pcfg.exports !== undefined && pcfg.exports !== null) {
            if (typeof pcfg.exports === 'string') {
                if (subpath !== '.') return null;
                const url = new URL(pcfg.exports, pkgUrl).href;
                try {
                    if (await this.finalizeResolve(url, false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
                } catch  {}
                return null;
            } else if (!allDotKeys(pcfg.exports)) {
                if (subpath !== '.') return null;
                const targets1 = enumeratePackageTargets(pcfg.exports);
                for (const curTarget1 of targets1){
                    try {
                        if (await this.finalizeResolve(new URL(curTarget1, pkgUrl).href, false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
                    } catch  {}
                }
                return null;
            } else {
                let bestMatch;
                for (const expt of Object.keys(pcfg.exports)){
                    const targets2 = enumeratePackageTargets(pcfg.exports[expt]);
                    for (const curTarget2 of targets2){
                        if (curTarget2.indexOf('*') === -1) {
                            if (await this.finalizeResolve(new URL(curTarget2, pkgUrl).href, false, null, pkgUrl) === pkgUrl + subpath.slice(2)) {
                                if (bestMatch) {
                                    if (originalSpecifier.endsWith(bestMatch.slice(2))) {
                                        if (!originalSpecifier.endsWith(expt.slice(2))) continue;
                                    } else if (!originalSpecifier.endsWith(expt.slice(2))) {
                                        // Normal precedence = shortest export!
                                        if (expt.length < bestMatch.length) bestMatch = expt;
                                    }
                                }
                                bestMatch = expt;
                            }
                        } else {
                            const parts = curTarget2.split('*');
                            if (!subpath.startsWith(parts[0])) continue;
                            const matchEndIndex = subpath.indexOf(parts[1], parts[0].length);
                            if (matchEndIndex === -1) continue;
                            const match1 = subpath.slice(parts[0].length, matchEndIndex);
                            const substitutedTarget = curTarget2.replace(/\*/g, match1);
                            if (subpath === substitutedTarget) {
                                const prefix = expt.slice(0, expt.indexOf('*'));
                                const suffix = expt.slice(expt.indexOf('*') + 1);
                                if (bestMatch) {
                                    if (originalSpecifier.endsWith(bestMatch.slice(2))) {
                                        if (!originalSpecifier.endsWith(expt.slice(2).replace('*', match1)) || bestMatch.startsWith(prefix) && bestMatch.endsWith(suffix)) continue;
                                    } else if (!originalSpecifier.endsWith(expt.slice(2).replace('*', match1))) {
                                        if (bestMatch.startsWith(prefix) && bestMatch.endsWith(suffix)) continue;
                                    }
                                }
                                bestMatch = expt.replace('*', match1);
                            }
                        }
                    }
                }
                return bestMatch;
            }
        } else {
            if (subpath !== '.') {
                try {
                    if (await this.finalizeResolve(new URL(subpath, new URL(pkgUrl)).href, false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
                } catch  {}
                return null;
            }
            try {
                if (typeof pcfg.main === 'string' && await this.finalizeResolve(await legacyMainResolve.call(this, pcfg.main, new URL(pkgUrl), originalSpecifier, pkgUrl), false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
            } catch  {}
            try {
                if (await this.finalizeResolve(await legacyMainResolve.call(this, null, new URL(pkgUrl), originalSpecifier, pkgUrl), false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
            } catch  {}
            try {
                if (typeof pcfg.browser === 'string' && await this.finalizeResolve(await legacyMainResolve.call(this, pcfg.browser, new URL(pkgUrl), originalSpecifier, pkgUrl), false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
            } catch  {}
            try {
                if (typeof pcfg.module === 'string' && await this.finalizeResolve(await legacyMainResolve.call(this, pcfg.module, new URL(pkgUrl), originalSpecifier, pkgUrl), false, null, pkgUrl) === pkgUrl + subpath.slice(2)) return '.';
                return null;
            } catch  {}
        }
        return null;
    }
    // Note: updates here must be tracked in function above
    async resolveExport(pkgUrl, subpath, cjsEnv, parentIsCjs, originalSpecifier, installer, parentUrl) {
        const env = cjsEnv ? this.cjsEnv : this.env;
        const pcfg = await this.getPackageConfig(pkgUrl) || {};
        if (typeof pcfg.exports === 'object' && pcfg.exports !== null && Object.keys(pcfg.exports).length === 0) {
            const stdlibTarget = {
                registry: 'npm',
                name: '@jspm/core',
                ranges: [
                    new SemverRange$2('*')
                ],
                unstable: true
            };
            const provider = installer.getProvider(stdlibTarget);
            const pkg = await this.resolveLatestTarget(stdlibTarget, provider);
            return this.resolveExport(this.pkgToUrl(pkg, provider), './nodelibs/@empty', cjsEnv, parentIsCjs, originalSpecifier, installer, parentUrl);
        }
        function throwExportNotDefined() {
            throw new JspmError(`No '${subpath}' exports subpath defined in ${pkgUrl} resolving ${originalSpecifier}${importedFrom(parentUrl)}.`, 'MODULE_NOT_FOUND');
        }
        if (pcfg.exports !== undefined && pcfg.exports !== null) {
            function allDotKeys(exports) {
                for(let p in exports){
                    if (p[0] !== '.') return false;
                }
                return true;
            }
            if (typeof pcfg.exports === 'string') {
                if (subpath === '.') return this.finalizeResolve(new URL(pcfg.exports, pkgUrl).href, parentIsCjs, installer, pkgUrl);
                else throwExportNotDefined();
            } else if (!allDotKeys(pcfg.exports)) {
                if (subpath === '.') return this.finalizeResolve(this.resolvePackageTarget(pcfg.exports, pkgUrl, cjsEnv, '', false), parentIsCjs, installer, pkgUrl);
                else throwExportNotDefined();
            } else {
                const match = getMapMatch(subpath, pcfg.exports);
                if (match) {
                    let replacement = '';
                    const wildcardIndex = match.indexOf('*');
                    if (wildcardIndex !== -1) {
                        replacement = subpath.slice(wildcardIndex, subpath.length - (match.length - wildcardIndex - 1));
                    } else if (match.endsWith('/')) {
                        replacement = subpath.slice(match.length);
                    }
                    const resolved = this.resolvePackageTarget(pcfg.exports[match], pkgUrl, cjsEnv, replacement, false);
                    if (resolved === null) throwExportNotDefined();
                    return this.finalizeResolve(resolved, parentIsCjs, installer, pkgUrl);
                }
                throwExportNotDefined();
            }
        } else {
            if (subpath === '.' || parentIsCjs && subpath === './') {
                if (env.includes('browser') && typeof pcfg.browser === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.browser, new URL(pkgUrl), originalSpecifier, pkgUrl), parentIsCjs, installer, pkgUrl);
                if (env.includes('module') && typeof pcfg.module === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.module, new URL(pkgUrl), originalSpecifier, pkgUrl), parentIsCjs, installer, pkgUrl);
                if (typeof pcfg.main === 'string') return this.finalizeResolve(await legacyMainResolve.call(this, pcfg.main, new URL(pkgUrl), originalSpecifier, pkgUrl), parentIsCjs, installer, pkgUrl);
                return this.finalizeResolve(await legacyMainResolve.call(this, null, new URL(pkgUrl), originalSpecifier, pkgUrl), parentIsCjs, installer, pkgUrl);
            } else {
                return this.finalizeResolve(new URL(subpath, new URL(pkgUrl)).href, parentIsCjs, installer, pkgUrl);
            }
        }
    }
    // async dlPackage (pkgUrl: string, outDirPath: string, beautify = false) {
    //   if (existsSync(outDirPath))
    //     throw new JspmError(`Checkout directory ${outDirPath} already exists.`);
    //   if (!pkgUrl.endsWith('/'))
    //     pkgUrl += '/';
    //   const dlPool = new Pool(20);
    //   const pkgContents: Record<string, string | ArrayBuffer> = Object.create(null);
    //   const pcfg = await this.getPackageConfig(pkgUrl);
    //   if (!pcfg || !pcfg.files || !(pcfg.files instanceof Array))
    //     throw new JspmError(`Unable to checkout ${pkgUrl} as there is no package files manifest.`);
    //   await Promise.all((pcfg.files).map(async file => {
    //     const url = pkgUrl + file;
    //     await dlPool.queue();
    //     try {
    //       const res = await fetch(url, this.fetchOpts);
    //       switch (res.status) {
    //         case 304:
    //         case 200:
    //           const contentType = res.headers && res.headers.get('content-type');
    //           let contents: string | ArrayBuffer = await res.arrayBuffer();
    //           if (beautify) {
    //             if (contentType === 'application/javascript') {
    //               // contents = jsBeautify(contents);
    //             }
    //             else if (contentType === 'application/json') {
    //               contents = JSON.stringify(JSON.parse(contents.toString()), null, 2);
    //             }
    //           }
    //           return pkgContents[file] = contents;
    //         default: throw new JspmError(`Invalid status code ${res.status} looking up ${url} - ${res.statusText}`);
    //       }
    //     }
    //     finally {
    //       dlPool.pop();
    //     }
    //   }));
    //   for (const file of Object.keys(pkgContents)) {
    //     const filePath = outDirPath + '/' + file;
    //     mkdirp.sync(path.dirname(filePath));
    //     writeFileSync(filePath, Buffer.from(pkgContents[file]));
    //   }
    // }
    async analyze(resolvedUrl, parentUrl, system, isRequire, retry = true) {
        const res = await fetch$1(resolvedUrl, this.fetchOpts);
        if (!res) throw new JspmError(`Unable to fetch URL "${resolvedUrl}" for ${parentUrl}`);
        switch(res.status){
            case 200:
            case 304:
                break;
            case 404:
                throw new JspmError(`Module not found: ${resolvedUrl}${importedFrom(parentUrl)}`, 'MODULE_NOT_FOUND');
            default:
                throw new JspmError(`Invalid status code ${res.status} loading ${resolvedUrl}. ${res.statusText}`);
        }
        try {
            var source = await res.text();
        } catch (e) {
            if (retry && (e.code === 'ERR_SOCKET_TIMEOUT' || e.code === 'ETIMEOUT' || e.code === 'ECONNRESET')) return this.analyze(resolvedUrl, parentUrl, system, isRequire, false);
            throw e;
        }
        // TODO: headers over extensions for non-file URLs
        try {
            if (resolvedUrl.endsWith('.ts') || resolvedUrl.endsWith('.tsx') || resolvedUrl.endsWith('.jsx')) return await createTsAnalysis(source, resolvedUrl);
            if (resolvedUrl.endsWith('.json')) {
                try {
                    JSON.parse(source);
                    return {
                        deps: [],
                        dynamicDeps: [],
                        cjsLazyDeps: null,
                        size: source.length,
                        format: 'json'
                    };
                } catch  {}
            }
            const [imports, exports] = parse(source);
            if (imports.every((impt)=>impt.d > 0) && !exports.length && resolvedUrl.startsWith('file:')) {
                var ref;
                // Support CommonJS package boundary checks for non-ESM on file: protocol only
                if (isRequire) {
                    var ref1;
                    if (!(resolvedUrl.endsWith('.mjs') || resolvedUrl.endsWith('.js') && ((ref1 = await this.getPackageConfig(await this.getPackageBase(resolvedUrl))) === null || ref1 === void 0 ? void 0 : ref1.type) === 'module')) return createCjsAnalysis(imports, source, resolvedUrl);
                } else if (resolvedUrl.endsWith('.cjs') || resolvedUrl.endsWith('.js') && ((ref = await this.getPackageConfig(await this.getPackageBase(resolvedUrl))) === null || ref === void 0 ? void 0 : ref.type) !== 'module') {
                    return createCjsAnalysis(imports, source, resolvedUrl);
                }
            }
            return system ? createSystemAnalysis(source, imports, resolvedUrl) : createEsmAnalysis(imports, source, resolvedUrl);
        } catch (e1) {
            if (!e1.message || !e1.message.startsWith('Parse error @:')) throw e1;
            // fetch is _unstable_!!!
            // so we retry the fetch first
            if (retry) {
                try {
                    return this.analyze(resolvedUrl, parentUrl, system, isRequire, false);
                } catch  {}
            }
            // TODO: better parser errors
            if (e1.message && e1.message.startsWith('Parse error @:')) {
                const [topline] = e1.message.split('\n', 1);
                const pos = topline.slice(14);
                let [line, col] = pos.split(':');
                const lines = source.split('\n');
                let errStack = '';
                if (line > 1) errStack += '\n  ' + lines[line - 2];
                errStack += '\n> ' + lines[line - 1];
                errStack += '\n  ' + ' '.repeat(col - 1) + '^';
                if (lines.length > 1) errStack += '\n  ' + lines[line];
                throw new JspmError(`${errStack}\n\nError parsing ${resolvedUrl}:${pos}`);
            }
            throw e1;
        }
    }
    // Note: changes to this function must be updated enumeratePackageTargets too
    resolvePackageTarget(target, packageUrl, cjsEnv, subpath, isImport) {
        if (typeof target === 'string') {
            if (target === '.') {
                // special dot export for file packages
                return packageUrl.slice(0, -1);
            }
            if (!target.startsWith('./')) {
                if (isImport) return target;
                throw new Error(`Invalid exports target ${target} resolving ./${subpath} in ${packageUrl}`);
            }
            if (!target.startsWith('./')) throw new Error('Invalid ');
            if (subpath === '') return new URL(target, packageUrl).href;
            if (target.indexOf('*') !== -1) {
                return new URL(target.replace(/\*/g, subpath), packageUrl).href;
            } else if (target.endsWith('/')) {
                return new URL(target + subpath, packageUrl).href;
            } else {
                throw new Error(`Expected pattern or path export resolving ./${subpath} in ${packageUrl}`);
            }
        } else if (typeof target === 'object' && target !== null && !Array.isArray(target)) {
            for(const condition in target){
                if (condition === 'default' || (cjsEnv ? this.cjsEnv : this.env).includes(condition)) {
                    const resolved = this.resolvePackageTarget(target[condition], packageUrl, cjsEnv, subpath, isImport);
                    if (resolved) return resolved;
                }
            }
        } else if (Array.isArray(target)) {
            // TODO: Validation for arrays
            for (const targetFallback of target){
                return this.resolvePackageTarget(targetFallback, packageUrl, cjsEnv, subpath, isImport);
            }
        }
        return null;
    }
    constructor(env, log, fetchOpts, preserveSymlinks = false){
        this.pcfgPromises = Object.create(null);
        this.pcfgs = Object.create(null);
        this.preserveSymlinks = false;
        this.providers = defaultProviders;
        if (env.includes('require')) throw new Error('Cannot manually pass require condition');
        if (!env.includes('import')) env.push('import');
        this.env = env;
        this.cjsEnv = this.env.map((e)=>e === 'import' ? 'require' : e);
        this.log = log;
        this.fetchOpts = fetchOpts;
        this.preserveSymlinks = preserveSymlinks;
    }
}
function enumeratePackageTargets(target, targets = new Set()) {
    if (typeof target === 'string') {
        targets.add(target);
    } else if (typeof target === 'object' && target !== null && !Array.isArray(target)) {
        for(const condition in target){
            enumeratePackageTargets(target[condition], targets);
        }
        return targets;
    } else if (Array.isArray(target)) {
        // TODO: Validation for arrays
        for (const targetFallback of target){
            enumeratePackageTargets(targetFallback, targets);
            return targets;
        }
    }
    return targets;
}
async function legacyMainResolve(main, pkgUrl, originalSpecifier, parentUrl) {
    let guess;
    if (main) {
        if (await this.exists(guess = new URL(`./${main}/index.js`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}/index.json`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}/index.node`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}.js`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}.json`, pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL(`./${main}.node`, pkgUrl).href)) return guess;
    } else {
        if (pkgUrl.protocol !== 'file:' && await this.exists(guess = new URL('./mod.ts', pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL('./index.js', pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL('./index.json', pkgUrl).href)) return guess;
        if (await this.exists(guess = new URL('./index.node', pkgUrl).href)) return guess;
    }
    // Not found.
    throw new JspmError(`Unable to resolve ${main ? main + ' in ' : ''}${pkgUrl} resolving ${originalSpecifier}${importedFrom(parentUrl)}.`, 'MODULE_NOT_FOUND');
}
function getMapMatch(specifier, map) {
    if (specifier in map) return specifier;
    let bestMatch;
    for (const match of Object.keys(map)){
        const wildcardIndex = match.indexOf('*');
        if (!match.endsWith('/') && wildcardIndex === -1) continue;
        if (match.endsWith('/')) {
            if (specifier.startsWith(match)) {
                if (!bestMatch || match.length > bestMatch.length) bestMatch = match;
            }
        } else {
            const prefix = match.slice(0, wildcardIndex);
            const suffix = match.slice(wildcardIndex + 1);
            if (specifier.startsWith(prefix) && specifier.endsWith(suffix) && specifier.length > prefix.length + suffix.length) {
                if (!bestMatch || !bestMatch.startsWith(prefix) || !bestMatch.endsWith(suffix)) bestMatch = match;
            }
        }
    }
    return bestMatch;
}
function allDotKeys(exports) {
    for(let p in exports){
        if (p[0] !== '.') return false;
    }
    return true;
}

// @ts-ignore
let createHash;
function setCreateHash(_createHash) {
    createHash = _createHash;
}
async function getIntegrity(url, fetchOpts) {
    if (!createHash) ({ createHash  } = await import('crypto'));
    const res = await fetch$1(url, fetchOpts);
    const buf = await res.text();
    const hash = createHash('sha384');
    hash.update(buf);
    return 'sha384-' + hash.digest('base64');
}

const { Semver: Semver$1 , SemverRange  } = sver;
function pruneResolutions(resolutions, to) {
    const newResolutions = {
        primary: Object.create(null),
        secondary: Object.create(null),
        flattened: Object.create(null)
    };
    for (const [name, parent] of to){
        if (!parent) {
            newResolutions.primary[name] = resolutions.primary[name];
        } else {
            newResolutions[parent] = newResolutions[parent] || {};
            newResolutions[parent][name] = resolutions.secondary[parent][name];
        }
    }
    return newResolutions;
}
function enumerateParentScopes(url) {
    const parentScopes = [];
    let separatorIndex = url.lastIndexOf('/');
    const protocolIndex = url.indexOf('://') + 1;
    if (separatorIndex !== url.length - 1) throw new Error('Internal error: expected package URL');
    while((separatorIndex = url.lastIndexOf('/', separatorIndex - 1)) !== protocolIndex){
        parentScopes.push(url.slice(0, separatorIndex + 1));
    }
    return parentScopes;
}
function getResolution(resolutions, name, pkgScope) {
    if (pkgScope && !pkgScope.endsWith('/')) throwInternalError(pkgScope);
    if (!pkgScope) return resolutions.primary[name] || null;
    const scope = resolutions.secondary[pkgScope];
    var ref;
    return (ref = scope === null || scope === void 0 ? void 0 : scope[name]) !== null && ref !== void 0 ? ref : null;
}
function getFlattenedResolution(resolutions, name, pkgScope, flattenedSubpath) {
    // no current scope -> check the flattened scopes
    const parentScopes = enumerateParentScopes(pkgScope);
    for (const scopeUrl of parentScopes){
        if (!resolutions.flattened[scopeUrl]) continue;
        const flatResolutions = resolutions.flattened[scopeUrl][name];
        if (!flatResolutions) continue;
        for (const flatResolution of flatResolutions){
            if (flatResolution.export === flattenedSubpath || flatResolution.export.endsWith('/') && flattenedSubpath.startsWith(flatResolution.export)) {
                return flatResolution.resolution;
            }
        }
    }
    return null;
}
function setConstraint(constraints, name, target, pkgScope = null) {
    if (pkgScope === null) constraints.primary[name] = target;
    else (constraints.secondary[pkgScope] = constraints.secondary[pkgScope] || Object.create(null))[name] = target;
}
function setResolution(resolutions, name, installUrl, pkgScope = null, installSubpath = null) {
    if (installSubpath === './std') throw new Error('NEIN');
    if (pkgScope && !pkgScope.endsWith('/')) throwInternalError(pkgScope);
    if (pkgScope === null) {
        const existing = resolutions.primary[name];
        if (existing && existing.installUrl === installUrl && existing.installSubpath === installSubpath) return false;
        resolutions.primary[name] = {
            installUrl,
            installSubpath
        };
        return true;
    } else {
        resolutions.secondary[pkgScope] = resolutions.secondary[pkgScope] || {};
        const existing1 = resolutions.secondary[pkgScope][name];
        if (existing1 && existing1.installUrl === installUrl && existing1.installSubpath === installSubpath) return false;
        resolutions.secondary[pkgScope][name] = {
            installUrl,
            installSubpath
        };
        return true;
    }
}
function extendLock(resolutions, newResolutions) {
    for (const pkg of Object.keys(newResolutions.primary)){
        resolutions.primary[pkg] = newResolutions.primary[pkg];
    }
    for (const pkgUrl of Object.keys(newResolutions.secondary)){
        if (resolutions[pkgUrl]) Object.assign(resolutions[pkgUrl] = Object.create(null), newResolutions[pkgUrl]);
        else resolutions.secondary[pkgUrl] = newResolutions.secondary[pkgUrl];
    }
    for (const scopeUrl of Object.keys(newResolutions.flattened)){
        if (resolutions[scopeUrl]) Object.assign(resolutions[scopeUrl], newResolutions[scopeUrl]);
        else resolutions.flattened[scopeUrl] = newResolutions.flattened[scopeUrl];
    }
}
function extendConstraints(constraints, newConstraints) {
    for (const pkg of Object.keys(newConstraints.primary)){
        constraints.primary[pkg] = newConstraints.primary[pkg];
    }
    for (const pkgUrl of Object.keys(newConstraints.secondary)){
        if (constraints[pkgUrl]) Object.assign(constraints[pkgUrl] = Object.create(null), newConstraints[pkgUrl]);
        else constraints.secondary[pkgUrl] = newConstraints.secondary[pkgUrl];
    }
}
function toVersionConstraints(pcfg, pkgUrl, defaultRegistry = 'npm', includeDev = false) {
    const constraints = Object.create(null);
    if (pcfg.dependencies) for (const name of Object.keys(pcfg.dependencies)){
        constraints[name] = newPackageTarget(pcfg.dependencies[name], pkgUrl, defaultRegistry, name);
    }
    if (pcfg.peerDependencies) for (const name1 of Object.keys(pcfg.peerDependencies)){
        if (name1 in constraints) continue;
        constraints[name1] = newPackageTarget(pcfg.peerDependencies[name1], pkgUrl, defaultRegistry, name1);
    }
    if (pcfg.optionalDependencies) for (const name2 of Object.keys(pcfg.optionalDependencies)){
        if (name2 in constraints) continue;
        constraints[name2] = newPackageTarget(pcfg.optionalDependencies[name2], pkgUrl, defaultRegistry, name2);
    }
    if (includeDev && pcfg.devDependencies) for (const name3 of Object.keys(pcfg.devDependencies)){
        if (name3 in constraints) continue;
        constraints[name3] = newPackageTarget(pcfg.devDependencies[name3], pkgUrl, defaultRegistry, name3);
    }
    return constraints;
}
function packageTargetFromExact(pkg, permitDowngrades = false) {
    const { registry , name , version  } = pkg;
    const v = new Semver$1(version);
    if (v.tag) return {
        registry,
        name,
        ranges: [
            new SemverRange(version)
        ],
        unstable: false
    };
    if (permitDowngrades) {
        if (v.major !== 0) return {
            registry,
            name,
            ranges: [
                new SemverRange(v.major)
            ],
            unstable: false
        };
        if (v.minor !== 0) return {
            registry,
            name,
            ranges: [
                new SemverRange(v.major + '.' + v.minor)
            ],
            unstable: false
        };
        return {
            registry,
            name,
            ranges: [
                new SemverRange(version)
            ],
            unstable: false
        };
    } else {
        return {
            registry,
            name,
            ranges: [
                new SemverRange('^' + version)
            ],
            unstable: false
        };
    }
}
function getInstallsFor(constraints, registry, name) {
    const installs = [];
    for (const alias of Object.keys(constraints.primary)){
        const target = constraints.primary[alias];
        if (target.registry === registry && target.name === name) installs.push({
            alias,
            pkgScope: null,
            ranges: target.ranges
        });
    }
    for (const pkgScope of Object.keys(constraints.secondary)){
        const scope = constraints.secondary[pkgScope];
        for (const alias1 of Object.keys(scope)){
            const target1 = scope[alias1];
            if (target1.registry === registry && target1.name === name) installs.push({
                alias: alias1,
                pkgScope,
                ranges: target1.ranges
            });
        }
    }
    return installs;
}
async function extractLockConstraintsAndMap(map, preloadUrls, mapUrl, rootUrl, defaultRegistry, resolver) {
    const lock = {
        primary: Object.create(null),
        secondary: Object.create(null),
        flattened: Object.create(null)
    };
    const maps = {
        imports: Object.create(null),
        scopes: Object.create(null)
    };
    // Primary version constraints taken from the map configuration base (if found)
    const primaryBase = await resolver.getPackageBase(mapUrl.href);
    const primaryPcfg = await resolver.getPackageConfig(primaryBase);
    const constraints = {
        primary: primaryPcfg ? toVersionConstraints(primaryPcfg, new URL(primaryBase), defaultRegistry, true) : Object.create(null),
        secondary: Object.create(null)
    };
    const pkgUrls = new Set();
    for (const key of Object.keys(map.imports || {})){
        if (isPlain(key)) {
            const parsedKey = parsePkg(key);
            const targetUrl = resolveUrl(map.imports[key], mapUrl, rootUrl);
            const parsedTarget = resolver.parseUrlPkg(targetUrl);
            const pkgUrl = parsedTarget ? resolver.pkgToUrl(parsedTarget.pkg, parsedTarget.source) : await resolver.getPackageBase(targetUrl);
            const subpath = '.' + targetUrl.slice(pkgUrl.length - 1);
            pkgUrls.add(pkgUrl);
            const exportSubpath = parsedTarget && await resolver.getExportResolution(pkgUrl, subpath, key);
            if (exportSubpath) {
                // Imports resolutions that resolve as expected can be skipped
                if (key[0] === '#') continue;
                // If there is no constraint, make one as the semver major on the current version
                if (!constraints.primary[parsedKey.pkgName]) constraints.primary[parsedKey.pkgName] = parsedTarget ? packageTargetFromExact(parsedTarget.pkg) : pkgUrl;
                // In the case of subpaths having diverging versions, we force convergence on one version
                // Only scopes permit unpacking
                let installSubpath = null;
                if (parsedKey.subpath !== exportSubpath) {
                    if (parsedKey.subpath === '.') {
                        installSubpath = exportSubpath;
                    } else if (exportSubpath === '.') {
                        installSubpath = false;
                    // throw new Error('CASE B');
                    } else {
                        if (exportSubpath.endsWith(parsedKey.subpath.slice(1))) installSubpath = exportSubpath.slice(0, parsedKey.subpath.length);
                    }
                }
                if (installSubpath !== false) {
                    setResolution(lock, parsedKey.pkgName, pkgUrl, null, installSubpath);
                    continue;
                }
            }
        }
        // Fallback -> Custom import with normalization
        maps.imports[isPlain(key) ? key : resolveUrl(key, mapUrl, rootUrl)] = resolveUrl(map.imports[key], mapUrl, rootUrl);
    }
    for (const scopeUrl of Object.keys(map.scopes || {})){
        var ref;
        const resolvedScopeUrl = (ref = resolveUrl(scopeUrl, mapUrl, rootUrl)) !== null && ref !== void 0 ? ref : scopeUrl;
        const scopePkgUrl = await resolver.getPackageBase(resolvedScopeUrl);
        const flattenedScope = new URL(scopePkgUrl).pathname === '/';
        pkgUrls.add(scopePkgUrl);
        const scope = map.scopes[scopeUrl];
        for (const key1 of Object.keys(scope)){
            if (isPlain(key1)) {
                const targetUrl1 = resolveUrl(scope[key1], mapUrl, rootUrl);
                const parsedTarget1 = resolver.parseUrlPkg(targetUrl1);
                const pkgUrl1 = parsedTarget1 ? resolver.pkgToUrl(parsedTarget1.pkg, parsedTarget1.source) : await resolver.getPackageBase(targetUrl1);
                const subpath1 = '.' + targetUrl1.slice(pkgUrl1.length - 1);
                pkgUrls.add(pkgUrl1);
                const exportSubpath1 = parsedTarget1 && await resolver.getExportResolution(pkgUrl1, subpath1, key1);
                if (exportSubpath1) {
                    // Imports resolutions that resolve as expected can be skipped
                    if (key1[0] === '#') continue;
                    const parsedKey1 = parsePkg(key1);
                    // If there is no constraint, we just make one as the semver major on the current version
                    if (!constraints.primary[parsedKey1.pkgName]) constraints.primary[parsedKey1.pkgName] = parsedTarget1 ? packageTargetFromExact(parsedTarget1.pkg) : pkgUrl1;
                    // In the case of subpaths having diverging versions, we force convergence on one version
                    // Only scopes permit unpacking
                    let installSubpath1 = null;
                    if (parsedKey1.subpath !== exportSubpath1) {
                        if (parsedKey1.subpath === '.') {
                            installSubpath1 = exportSubpath1;
                        } else if (exportSubpath1 === '.') {
                            installSubpath1 = false;
                        // throw new Error('CASE B');
                        } else {
                            if (exportSubpath1.endsWith(parsedKey1.subpath.slice(1))) installSubpath1 = exportSubpath1.slice(0, parsedKey1.subpath.length);
                        }
                    }
                    if (installSubpath1 !== false) {
                        if (flattenedScope) {
                            const flattened = lock.flattened[scopePkgUrl] = lock.flattened[scopePkgUrl] || {};
                            flattened[parsedKey1.pkgName] = flattened[parsedKey1.pkgName] || [];
                            flattened[parsedKey1.pkgName].push({
                                export: parsedKey1.subpath,
                                resolution: {
                                    installUrl: pkgUrl1,
                                    installSubpath: installSubpath1
                                }
                            });
                        } else {
                            setResolution(lock, parsedKey1.pkgName, pkgUrl1, scopePkgUrl, installSubpath1);
                        }
                        continue;
                    }
                }
            }
            // Fallback -> Custom import with normalization
            (maps.scopes[resolvedScopeUrl] = maps.scopes[resolvedScopeUrl] || Object.create(null))[isPlain(key1) ? key1 : resolveUrl(key1, mapUrl, rootUrl)] = resolveUrl(scope[key1], mapUrl, rootUrl);
        }
    }
    // for every package we resolved, add their package constraints into the list of constraints
    await Promise.all([
        ...pkgUrls
    ].map(async (pkgUrl)=>{
        if (!isURL(pkgUrl)) return;
        const pcfg = await getPackageConfig(pkgUrl);
        if (pcfg) constraints.secondary[pkgUrl] = toVersionConstraints(pcfg, new URL(pkgUrl), defaultRegistry, false);
    }));
    // TODO: allow preloads to inform used versions somehow
    // for (const url of preloadUrls) {
    //   const resolved = resolveUrl(url, mapUrl, rootUrl).href;
    //   const providerPkg = resolver.parseUrlPkg(resolved);
    //   if (providerPkg) {
    //     const pkgUrl = await resolver.getPackageBase(mapUrl.href);
    //   }
    // }
    return {
        lock,
        constraints,
        maps
    };
}

const { Semver  } = sver;
class Installer {
    visitInstalls(visitor) {
        if (visitor(this.installs.primary, null)) return;
        for (const scopeUrl of Object.keys(this.installs.secondary)){
            if (visitor(this.installs.secondary[scopeUrl], scopeUrl)) return;
        }
    }
    startInstall() {
        if (this.installing) throw new Error('Internal error: already installing');
        this.installing = true;
        this.newInstalls = false;
        this.added = new Map();
    }
    finishInstall() {
        this.installing = false;
    }
    async lockInstall(installs, pkgUrl = this.installBaseUrl, prune = true) {
        const visited = new Set();
        const visitInstall = async (name, pkgUrl)=>{
            if (visited.has(name + '##' + pkgUrl)) return;
            visited.add(name + '##' + pkgUrl);
            const install = await this.install(name, 'existing', pkgUrl, '.');
            if (install && typeof install !== 'string') {
                const { installUrl  } = install;
                const deps = await this.resolver.getDepList(installUrl);
                const existingDeps = Object.keys(this.installs.secondary[installUrl] || {});
                await Promise.all([
                    ...new Set([
                        ...deps,
                        ...existingDeps
                    ])
                ].map((dep)=>visitInstall(dep, installUrl)));
            }
        };
        await Promise.all(installs.map((install)=>visitInstall(install, pkgUrl)));
        if (prune) {
            const pruneList = [
                ...visited
            ].map((item)=>{
                const [name, pkgUrl] = item.split('##');
                return [
                    name,
                    pkgUrl
                ];
            });
            this.installs = pruneResolutions(this.installs, pruneList);
        }
    }
    getProvider(target) {
        let provider = this.defaultProvider;
        for (const name of Object.keys(this.providers)){
            if (name.endsWith(':') && target.registry === name.slice(0, -1) || target.name.startsWith(name) && (target.name.length === name.length || target.name[name.length] === '/')) {
                provider = {
                    provider: this.providers[name],
                    layer: 'default'
                };
                const layerIndex = provider.provider.indexOf('.');
                if (layerIndex !== -1) {
                    provider.layer = provider.provider.slice(layerIndex + 1);
                    provider.provider = provider.provider.slice(0, layerIndex);
                }
                break;
            }
        }
        return provider;
    }
    async installTarget(pkgName, { pkgTarget , installSubpath  }, traceSubpath, mode, pkgScope, parentUrl) {
        if (this.opts.freeze && mode === 'existing') throw new JspmError(`"${pkgName}" is not installed in the current map to freeze install, imported from ${parentUrl}.`, 'ERR_NOT_INSTALLED');
        // resolutions are authoritative at the top-level
        if (this.resolutions[pkgName]) {
            const resolutionTarget = newPackageTarget(this.resolutions[pkgName], this.opts.baseUrl, this.defaultRegistry, pkgName);
            resolutionTarget.installSubpath = installSubpath;
            if (JSON.stringify(pkgTarget) !== JSON.stringify(resolutionTarget.pkgTarget)) return this.installTarget(pkgName, resolutionTarget, traceSubpath, mode, pkgScope, parentUrl);
        }
        if (pkgTarget instanceof URL) {
            this.log('install', `${pkgName} ${pkgScope} -> ${pkgTarget.href}`);
            const installUrl = pkgTarget.href + (pkgTarget.href.endsWith('/') ? '' : '/');
            this.newInstalls = setResolution(this.installs, pkgName, installUrl, pkgScope, installSubpath);
            return {
                installUrl,
                installSubpath
            };
        }
        const provider = this.getProvider(pkgTarget);
        if ((this.opts.freeze || mode.includes('existing') || pkgScope !== null) && !this.opts.latest) {
            const pkg = this.getBestExistingMatch(pkgTarget);
            if (pkg) {
                this.log('install', `${pkgName} ${pkgScope} -> ${pkg} (existing match)`);
                const installUrl1 = this.resolver.pkgToUrl(pkg, provider);
                this.newInstalls = setResolution(this.installs, pkgName, installUrl1, pkgScope, installSubpath);
                setConstraint(this.constraints, pkgName, pkgTarget, pkgScope);
                return {
                    installUrl: installUrl1,
                    installSubpath
                };
            }
        }
        const latestPkg = await this.resolver.resolveLatestTarget(pkgTarget, provider, parentUrl);
        const pkgUrl = this.resolver.pkgToUrl(latestPkg, provider);
        const installed = getInstallsFor(this.constraints, latestPkg.registry, latestPkg.name);
        if (!this.opts.freeze && latestPkg && !this.tryUpgradeAllTo(latestPkg, pkgUrl, installed)) {
            if (pkgScope && !this.opts.latest) {
                const pkg1 = this.getBestExistingMatch(pkgTarget);
                // cannot upgrade to latest -> stick with existing resolution (if compatible)
                if (pkg1) {
                    this.log('install', `${pkgName} ${pkgScope} -> ${latestPkg} (existing match not latest)`);
                    const installUrl2 = this.resolver.pkgToUrl(pkg1, provider);
                    this.newInstalls = setResolution(this.installs, pkgName, installUrl2, pkgScope, installSubpath);
                    setConstraint(this.constraints, pkgName, pkgTarget, pkgScope);
                    return {
                        installUrl: installUrl2,
                        installSubpath
                    };
                }
            }
        }
        this.log('install', `${pkgName} ${pkgScope} -> ${pkgUrl} ${installSubpath ? installSubpath : '<no-subpath>'} (latest)`);
        this.newInstalls = setResolution(this.installs, pkgName, pkgUrl, pkgScope, installSubpath);
        setConstraint(this.constraints, pkgName, pkgTarget, pkgScope);
        this.upgradeSupportedTo(latestPkg, pkgUrl, installed);
        return {
            installUrl: pkgUrl,
            installSubpath
        };
    }
    async install(pkgName, mode, pkgScope = null, traceSubpath, parentUrl = this.installBaseUrl) {
        var ref, ref1, ref2, ref3;
        if (!this.installing) throwInternalError('Not installing');
        if (this.resolutions[pkgName]) return this.installTarget(pkgName, newPackageTarget(this.resolutions[pkgName], this.opts.baseUrl, this.defaultRegistry, pkgName), traceSubpath, mode, pkgScope, parentUrl);
        if (!this.opts.reset) {
            const existingResolution = getResolution(this.installs, pkgName, pkgScope);
            if (existingResolution) return existingResolution;
            // flattened resolution cascading for secondary
            if (pkgScope && mode.includes('existing') && !this.opts.latest || pkgScope && mode.includes('new') && this.opts.freeze) {
                const flattenedResolution = getFlattenedResolution(this.installs, pkgName, pkgScope, traceSubpath);
                // resolved flattened resolutions become real resolutions as they get picked up
                if (flattenedResolution) {
                    this.newInstalls = setResolution(this.installs, pkgName, flattenedResolution.installUrl, pkgScope, flattenedResolution.installSubpath);
                    return flattenedResolution;
                }
            }
        }
        const definitelyPkgScope = pkgScope || await this.resolver.getPackageBase(parentUrl);
        const pcfg = await this.resolver.getPackageConfig(definitelyPkgScope) || {};
        // package dependencies
        const installTarget = ((ref = pcfg.dependencies) === null || ref === void 0 ? void 0 : ref[pkgName]) || ((ref1 = pcfg.peerDependencies) === null || ref1 === void 0 ? void 0 : ref1[pkgName]) || ((ref2 = pcfg.optionalDependencies) === null || ref2 === void 0 ? void 0 : ref2[pkgName]) || pkgScope === this.installBaseUrl && ((ref3 = pcfg.devDependencies) === null || ref3 === void 0 ? void 0 : ref3[pkgName]);
        if (installTarget) {
            const target = newPackageTarget(installTarget, new URL(definitelyPkgScope), this.defaultRegistry, pkgName);
            return this.installTarget(pkgName, target, traceSubpath, mode, pkgScope, parentUrl);
        }
        const specifier = pkgName + (traceSubpath ? traceSubpath.slice(1) : '');
        const builtin = this.resolver.resolveBuiltin(specifier);
        if (builtin) {
            if (typeof builtin === 'string') return builtin;
            return this.installTarget(specifier, builtin.target, traceSubpath, mode, pkgScope, parentUrl);
        }
        // existing primary version fallback
        if (this.installs.primary[pkgName]) {
            const { installUrl  } = getResolution(this.installs, pkgName, null);
            return {
                installUrl,
                installSubpath: null
            };
        }
        // global install fallback
        const target1 = newPackageTarget('*', new URL(definitelyPkgScope), this.defaultRegistry, pkgName);
        const { installUrl: installUrl1  } = await this.installTarget(pkgName, target1, null, mode, pkgScope, parentUrl);
        return {
            installUrl: installUrl1,
            installSubpath: null
        };
    }
    // Note: maintain this live instead of recomputing
    get pkgUrls() {
        const pkgUrls = new Set();
        for (const pkgUrl of Object.values(this.installs.primary)){
            pkgUrls.add(pkgUrl.installUrl);
        }
        for (const scope of Object.keys(this.installs.secondary)){
            for (const { installUrl  } of Object.values(this.installs.secondary[scope])){
                pkgUrls.add(installUrl);
            }
        }
        for (const flatScope of Object.keys(this.installs.flattened)){
            for (const { resolution: { installUrl: installUrl1  }  } of Object.values(this.installs.flattened[flatScope]).flat()){
                pkgUrls.add(installUrl1);
            }
        }
        return pkgUrls;
    }
    getBestExistingMatch(matchPkg) {
        let bestMatch = null;
        for (const pkgUrl of this.pkgUrls){
            const pkg = this.resolver.parseUrlPkg(pkgUrl);
            if (pkg && this.inRange(pkg.pkg, matchPkg)) {
                if (bestMatch) bestMatch = Semver.compare(new Semver(bestMatch.version), pkg.pkg.version) === -1 ? pkg.pkg : bestMatch;
                else bestMatch = pkg.pkg;
            }
        }
        return bestMatch;
    }
    inRange(pkg, target) {
        return pkg.registry === target.registry && pkg.name === target.name && target.ranges.some((range)=>range.has(pkg.version, true));
    }
    // upgrade all existing packages to this package if possible
    tryUpgradeAllTo(pkg, pkgUrl, installed) {
        const pkgVersion = new Semver(pkg.version);
        let allCompatible = true;
        for (const { ranges  } of installed){
            if (ranges.every((range)=>!range.has(pkgVersion))) allCompatible = false;
        }
        if (!allCompatible) return false;
        // if every installed version can support this new version, update them all
        for (const { alias , pkgScope  } of installed){
            const resolution = getResolution(this.installs, alias, pkgScope);
            if (!resolution) continue;
            const { installSubpath  } = resolution;
            this.newInstalls = setResolution(this.installs, alias, pkgUrl, pkgScope, installSubpath);
        }
        return true;
    }
    // upgrade some exsiting packages to the new install
    upgradeSupportedTo(pkg, pkgUrl, installed) {
        const pkgVersion = new Semver(pkg.version);
        for (const { alias , pkgScope , ranges  } of installed){
            const resolution = getResolution(this.installs, alias, pkgScope);
            if (!resolution) continue;
            if (!ranges.some((range)=>range.has(pkgVersion, true))) continue;
            const { installSubpath  } = resolution;
            this.newInstalls = setResolution(this.installs, alias, pkgUrl, pkgScope, installSubpath);
        }
    }
    constructor(baseUrl, opts, log, resolver){
        this.installing = false;
        this.newInstalls = false;
        this.added = new Map();
        this.hasLock = false;
        this.defaultProvider = {
            provider: 'jspm',
            layer: 'default'
        };
        this.defaultRegistry = 'npm';
        this.log = log;
        this.resolver = resolver;
        this.resolutions = opts.resolutions || {};
        this.installBaseUrl = baseUrl;
        this.opts = opts;
        this.hasLock = !!opts.lock;
        this.installs = opts.lock || {
            primary: Object.create(null),
            secondary: Object.create(null),
            flattened: Object.create(null)
        };
        this.constraints = {
            primary: Object.create(null),
            secondary: Object.create(null)
        };
        if (opts.defaultRegistry) this.defaultRegistry = opts.defaultRegistry;
        if (opts.defaultProvider) this.defaultProvider = {
            provider: opts.defaultProvider.split('.')[0],
            layer: opts.defaultProvider.split('.')[1] || 'default'
        };
        this.providers = Object.assign({}, registryProviders);
        if (opts.providers) Object.assign(this.providers, opts.providers);
    }
}

function combineSubpaths(installSubpath, traceSubpath) {
    return installSubpath === null || traceSubpath === '.' ? installSubpath || traceSubpath : `${installSubpath}${traceSubpath.slice(1)}`;
}
class TraceMap {
    async addInputMap(map, mapUrl = this.mapUrl, rootUrl = this.rootUrl, preloads) {
        return this.processInputMap = this.processInputMap.then(async ()=>{
            const inMap = new ImportMap({
                map,
                mapUrl,
                rootUrl
            }).rebase(this.mapUrl, this.rootUrl);
            const pins = Object.keys(inMap.imports || []);
            for (const pin of pins){
                if (!this.pins.includes(pin)) this.pins.push(pin);
            }
            const { maps , lock , constraints  } = await extractLockConstraintsAndMap(inMap, preloads, mapUrl, rootUrl, this.installer.defaultRegistry, this.resolver);
            this.inputMap.extend(maps);
            extendLock(this.installer.installs, lock);
            extendConstraints(this.installer.constraints, constraints);
        });
    }
    async visit(specifier, opts, parentUrl, seen = new Set()) {
        var ref;
        if (!parentUrl) throw new Error('Internal error: expected parentUrl');
        // TODO: support ignoring prefixes?
        if ((ref = this.opts.ignore) === null || ref === void 0 ? void 0 : ref.includes(specifier)) return;
        if (seen.has(`${specifier}##${parentUrl}`)) return;
        seen.add(`${specifier}##${parentUrl}`);
        // This should probably be baseUrl?
        const resolved = await this.resolve(specifier, parentUrl, opts.mode, opts.toplevel);
        const entry = await this.getTraceEntry(resolved, parentUrl);
        if (opts.visitor) {
            const stop = await opts.visitor(specifier, parentUrl, resolved, opts.toplevel, entry);
            if (stop) return;
        }
        if (!entry) return;
        let allDeps = [
            ...entry.deps
        ];
        if (entry.dynamicDeps.length && !opts.static) {
            for (const dep of entry.dynamicDeps){
                if (!allDeps.includes(dep)) allDeps.push(dep);
            }
        }
        if (entry.cjsLazyDeps && !opts.static) {
            for (const dep1 of entry.cjsLazyDeps){
                if (!allDeps.includes(dep1)) allDeps.push(dep1);
            }
        }
        // Trace install first bare specifier -> pin and start scoping
        const toplevel = opts.toplevel;
        if (toplevel && (isPlain(specifier) || isMappableScheme(specifier))) {
            // if (this.pins.indexOf(specifier) === -1)
            //   this.pins.push(specifier);
            opts = {
                ...opts,
                toplevel: false
            };
        }
        await Promise.all(allDeps.map(async (dep)=>{
            if (dep.indexOf('*') !== -1) {
                this.log('todo', 'Handle wildcard trace ' + dep + ' in ' + resolved);
                return;
            }
            await this.visit(dep, opts, resolved, seen);
        }));
    }
    async extractMap(modules) {
        const map = new ImportMap({
            mapUrl: this.mapUrl,
            rootUrl: this.rootUrl
        });
        // note this plucks custom top-level custom imports
        // we may want better control over this
        map.extend(this.inputMap);
        // re-drive all the traces to convergence
        do {
            this.installer.newInstalls = false;
            await Promise.all(modules.map(async (module)=>{
                await this.visit(module, {
                    mode: 'existing',
                    static: this.opts.static,
                    toplevel: true
                }, this.mapUrl.href);
            }));
        }while (this.installer.newInstalls)
        // The final loop gives us the mappings
        const staticList = new Set();
        const dynamicList = new Set();
        const dynamics = [];
        let list = staticList;
        const visitor = async (specifier, parentUrl, resolved, toplevel, entry)=>{
            if (!staticList.has(resolved)) list.add(resolved);
            if (entry) for (const dep of entry.dynamicDeps){
                dynamics.push([
                    dep,
                    resolved
                ]);
            }
            if (toplevel) {
                if (isPlain(specifier) || isMappableScheme(specifier)) {
                    var ref, ref1;
                    const existing = map.imports[specifier];
                    if (!existing || existing !== resolved && ((ref = this.tracedUrls) === null || ref === void 0 ? void 0 : (ref1 = ref[parentUrl]) === null || ref1 === void 0 ? void 0 : ref1.wasCJS)) {
                        map.set(specifier, resolved);
                    }
                }
            } else {
                if (isPlain(specifier) || isMappableScheme(specifier)) {
                    var ref2, ref3;
                    const scopeUrl = await this.resolver.getPackageBase(parentUrl);
                    const existing1 = (ref2 = map.scopes[scopeUrl]) === null || ref2 === void 0 ? void 0 : ref2[specifier];
                    if (!existing1) {
                        map.set(specifier, resolved, scopeUrl);
                    } else if (existing1 !== resolved && ((ref3 = map.scopes[parentUrl]) === null || ref3 === void 0 ? void 0 : ref3[specifier]) !== resolved) {
                        map.set(specifier, resolved, parentUrl);
                    }
                }
            }
        };
        const seen = new Set();
        await Promise.all(modules.map(async (module)=>{
            await this.visit(module, {
                static: true,
                visitor,
                mode: 'existing',
                toplevel: true
            }, this.mapUrl.href, seen);
        }));
        list = dynamicList;
        await Promise.all(dynamics.map(async ([specifier, parent])=>{
            await this.visit(specifier, {
                visitor,
                mode: 'existing',
                toplevel: false
            }, parent, seen);
        }));
        if (this.installer.newInstalls) ;
        return {
            map,
            staticDeps: [
                ...staticList
            ],
            dynamicDeps: [
                ...dynamicList
            ]
        };
    }
    startInstall() {
        this.installer.startInstall();
    }
    async finishInstall(modules = this.pins) {
        const result = await this.extractMap(modules);
        this.installer.finishInstall();
        return result;
    }
    async add(name, target) {
        await this.installer.installTarget(name, target, null, 'new', null, this.mapUrl.href);
    }
    // async addAllPkgMappings (name: string, pkgUrl: string, parentPkgUrl: string | null = null) {
    //   const [url, subpathFilter] = pkgUrl.split('|');
    //   const exports = await this.resolver.getExports(url + (url.endsWith('/') ? '' : '/'), env, subpathFilter);
    //   for (const key of Object.keys(exports)) {
    //     if (key.endsWith('!cjs'))
    //       continue;
    //     if (!exports[key])
    //       continue;
    //     if (key.endsWith('*'))
    //       continue;
    //     let target = new URL(exports[key], url).href;
    //     if (!exports[key].endsWith('/') && target.endsWith('/'))
    //       target = target.slice(0, -1);
    //     this.map.addMapping(name + key.slice(1), target, parentPkgUrl);
    //   }
    // }
    /**
   * @returns `resolved` - either a URL `string` pointing to the module or `null` if the specifier should be ignored.
   */ async resolve(specifier, parentUrl, mode, toplevel) {
        var ref, ref1;
        const cjsEnv = (ref = this.tracedUrls[parentUrl]) === null || ref === void 0 ? void 0 : ref.wasCJS;
        const parentPkgUrl = await this.resolver.getPackageBase(parentUrl);
        if (!parentPkgUrl) throwInternalError();
        const parentIsCjs = ((ref1 = this.tracedUrls[parentUrl]) === null || ref1 === void 0 ? void 0 : ref1.format) === 'commonjs';
        if ((!isPlain(specifier) || specifier === '..') && !isMappableScheme(specifier)) {
            let resolvedUrl = new URL(specifier, parentUrl);
            if (!isFetchProtocol(resolvedUrl.protocol)) throw new JspmError(`Found unexpected protocol ${resolvedUrl.protocol}${importedFrom(parentUrl)}`);
            const resolvedHref = resolvedUrl.href;
            let finalized = await this.resolver.realPath(await this.resolver.finalizeResolve(resolvedHref, parentIsCjs, this.installer, parentPkgUrl));
            // handle URL mappings
            const urlResolved = this.inputMap.resolve(finalized, parentUrl);
            // TODO: avoid this hack - perhaps solved by conditional maps
            if (urlResolved !== finalized && !urlResolved.startsWith('node:') && !urlResolved.startsWith('deno:')) {
                finalized = urlResolved;
            }
            if (finalized !== resolvedHref) {
                this.inputMap.set(resolvedHref.endsWith('/') ? resolvedHref.slice(0, -1) : resolvedHref, finalized);
                resolvedUrl = new URL(finalized);
            }
            this.log('resolve', `${specifier} ${parentUrl} -> ${resolvedUrl}`);
            return resolvedUrl.href;
        }
        // Subscope override
        const scopeMatches = getScopeMatches(parentUrl, this.inputMap.scopes, this.inputMap.mapUrl);
        const pkgSubscopes = scopeMatches.filter(([, url])=>url.startsWith(parentPkgUrl));
        if (pkgSubscopes.length) {
            for (const [scope] of pkgSubscopes){
                const mapMatch = getMapMatch$1(specifier, this.inputMap.scopes[scope]);
                if (mapMatch) {
                    const resolved = await this.resolver.realPath(resolveUrl(this.inputMap.scopes[scope][mapMatch] + specifier.slice(mapMatch.length), this.inputMap.mapUrl, this.inputMap.rootUrl));
                    this.log('resolve', `${specifier} ${parentUrl} -> ${resolved}`);
                    return resolved;
                }
            }
        }
        // Scope override
        const userScopeMatch = scopeMatches.find(([, url])=>url === parentPkgUrl);
        if (userScopeMatch) {
            const imports = this.inputMap.scopes[userScopeMatch[0]];
            const userImportsMatch = getMapMatch$1(specifier, imports);
            const userImportsResolved = userImportsMatch ? await this.resolver.realPath(resolveUrl(imports[userImportsMatch] + specifier.slice(userImportsMatch.length), this.inputMap.mapUrl, this.inputMap.rootUrl)) : null;
            if (userImportsResolved) {
                this.log('resolve', `${specifier} ${parentUrl} -> ${userImportsResolved}`);
                return userImportsResolved;
            }
        }
        // User import overrides
        const userImportsMatch1 = getMapMatch$1(specifier, this.inputMap.imports);
        const userImportsResolved1 = userImportsMatch1 ? await this.resolver.realPath(resolveUrl(this.inputMap.imports[userImportsMatch1] + specifier.slice(userImportsMatch1.length), this.inputMap.mapUrl, this.inputMap.rootUrl)) : null;
        if (userImportsResolved1) {
            this.log('resolve', `${specifier} ${parentUrl} -> ${userImportsResolved1}`);
            return userImportsResolved1;
        }
        const parsed = parsePkg(specifier);
        if (!parsed) throw new JspmError(`Invalid package name ${specifier}`);
        const { pkgName , subpath  } = parsed;
        // Own name import
        const pcfg = await this.resolver.getPackageConfig(parentPkgUrl) || {};
        if (pcfg.exports && pcfg.name === pkgName) {
            const resolved1 = await this.resolver.realPath(await this.resolver.resolveExport(parentPkgUrl, subpath, cjsEnv, parentIsCjs, specifier, this.installer, new URL(parentUrl)));
            this.log('resolve', `${specifier} ${parentUrl} -> ${resolved1}`);
            return resolved1;
        }
        // Imports
        if (pcfg.imports && pkgName[0] === '#') {
            const match = getMapMatch$1(specifier, pcfg.imports);
            if (!match) throw new JspmError(`No '${specifier}' import defined in ${parentPkgUrl}${importedFrom(parentUrl)}.`);
            const target = this.resolver.resolvePackageTarget(pcfg.imports[match], parentPkgUrl, cjsEnv, specifier.slice(match.length), true);
            if (!isURL(target)) {
                return this.resolve(target, parentUrl, mode, toplevel);
            }
            const resolved2 = await this.resolver.realPath(target);
            this.log('resolve', `${specifier} ${parentUrl} -> ${resolved2}`);
            return resolved2;
        }
        // @ts-ignore
        const installed = await this.installer.install(pkgName, mode, toplevel ? null : parentPkgUrl, subpath, parentUrl);
        if (typeof installed === 'string') {
            return installed;
        } else if (installed) {
            const { installUrl , installSubpath  } = installed;
            const resolved3 = await this.resolver.realPath(await this.resolver.resolveExport(installUrl, combineSubpaths(installSubpath, subpath), cjsEnv, parentIsCjs, specifier, this.installer, new URL(parentUrl)));
            this.log('resolve', `${specifier} ${parentUrl} -> ${resolved3}`);
            return resolved3;
        }
        throw new JspmError(`No resolution in map for ${specifier}${importedFrom(parentUrl)}`);
    }
    async getTraceEntry(resolvedUrl, parentUrl) {
        if (resolvedUrl in this.tracedUrls) {
            const entry = this.tracedUrls[resolvedUrl];
            await entry.promise;
            return entry;
        }
        if (isBuiltinScheme(resolvedUrl)) return null;
        if (resolvedUrl.endsWith('/')) throw new JspmError(`Trailing "/" installs not supported installing ${resolvedUrl} for ${parentUrl}`);
        const traceEntry = this.tracedUrls[resolvedUrl] = {
            promise: null,
            wasCJS: false,
            deps: null,
            dynamicDeps: null,
            cjsLazyDeps: null,
            hasStaticParent: true,
            size: NaN,
            integrity: '',
            format: undefined
        };
        traceEntry.promise = (async ()=>{
            var ref;
            const parentIsCjs = ((ref = this.tracedUrls[parentUrl]) === null || ref === void 0 ? void 0 : ref.format) === 'commonjs';
            const { deps , dynamicDeps , cjsLazyDeps , size , format  } = await this.resolver.analyze(resolvedUrl, parentUrl, this.opts.system, parentIsCjs);
            traceEntry.format = format;
            traceEntry.size = size;
            traceEntry.deps = deps.sort();
            traceEntry.dynamicDeps = dynamicDeps.sort();
            traceEntry.cjsLazyDeps = cjsLazyDeps ? cjsLazyDeps.sort() : cjsLazyDeps;
            // wasCJS distinct from CJS because it applies to CJS transformed into ESM
            // from the resolver perspective
            const wasCJS = format === 'commonjs' || await this.resolver.wasCommonJS(resolvedUrl);
            if (wasCJS) traceEntry.wasCJS = true;
            traceEntry.promise = null;
        })();
        await traceEntry.promise;
        return traceEntry;
    }
    constructor(opts, log, resolver){
        this.cjsEnv = null;
        this.tracedUrls = {};
        this.pins = [];
        this.processInputMap = Promise.resolve();
        this.log = log;
        this.resolver = resolver;
        this.mapUrl = opts.mapUrl;
        this.rootUrl = opts.rootUrl || null;
        this.opts = opts;
        this.inputMap = new ImportMap({
            mapUrl: this.mapUrl,
            rootUrl: this.rootUrl
        });
        this.installer = new Installer(this.mapUrl.pathname.endsWith('/') ? this.mapUrl.href : `${this.mapUrl.href}/`, this.opts, this.log, this.resolver);
    }
}

function createLogger() {
    let resolveQueue;
    let queuePromise = new Promise((resolve)=>resolveQueue = resolve);
    let queue = [];
    const logStream = async function*() {
        while(true){
            while(queue.length)yield queue.shift();
            await queuePromise;
        }
    };
    function log(type, message) {
        if (queue.length) {
            queue.push({
                type,
                message
            });
        } else {
            queue = [
                {
                    type,
                    message
                }
            ];
            const _resolveQueue = resolveQueue;
            queuePromise = new Promise((resolve)=>resolveQueue = resolve);
            _resolveQueue();
        }
    }
    return {
        log,
        logStream
    };
}

var ref, ref1, ref2;
const isWindows = ((ref = globalThis.process) === null || ref === void 0 ? void 0 : ref.platform) === 'win32';
isWindows ? Object.keys((ref1 = globalThis.process) === null || ref1 === void 0 ? void 0 : ref1.env).find((e)=>Boolean(e.match(/^PATH$/i))) || 'Path' : 'PATH';
((ref2 = globalThis.process) === null || ref2 === void 0 ? void 0 : ref2.platform) === 'win32' ? ';' : ':';

const defaultStyle = {
    tab: '  ',
    newline: isWindows ? '\r\n' : '\n',
    trailingNewline: isWindows ? '\r\n' : '\n',
    indent: '',
    quote: '"'
};
function detectNewline(source) {
    let newLineMatch = source.match(/\r?\n|\r(?!\n)/);
    if (newLineMatch) return newLineMatch[0];
    return isWindows ? '\r\n' : '\n';
}
function detectIndent$1(source, newline) {
    let indent = undefined;
    // best-effort tab detection
    // yes this is overkill, but it avoids possibly annoying edge cases
    let lines = source.split(newline);
    for (const line of lines){
        const curIndent = line.match(/^\s*[^\s]/);
        if (curIndent && (indent === undefined || curIndent.length < indent.length)) indent = curIndent[0].slice(0, -1);
    }
    indent = indent || '';
    lines = lines.map((line)=>line.slice(indent.length));
    let tabSpaces = lines.map((line)=>{
        var ref;
        return ((ref = line.match(/^[ \t]*/)) === null || ref === void 0 ? void 0 : ref[0]) || '';
    }) || [];
    let tabDifferenceFreqs = new Map();
    let lastLength = 0;
    tabSpaces.forEach((tabSpace)=>{
        let diff = Math.abs(tabSpace.length - lastLength);
        if (diff !== 0) tabDifferenceFreqs.set(diff, (tabDifferenceFreqs.get(diff) || 0) + 1);
        lastLength = tabSpace.length;
    });
    let bestTabLength = 0;
    for (const tabLength of tabDifferenceFreqs.keys()){
        if (!bestTabLength || tabDifferenceFreqs.get(tabLength) >= tabDifferenceFreqs.get(bestTabLength)) bestTabLength = tabLength;
    }
    // having determined the most common spacing difference length,
    // generate samples of this tab length from the end of each line space
    // the most common sample is then the tab string
    let tabSamples = new Map();
    tabSpaces.forEach((tabSpace)=>{
        let sample = tabSpace.substr(tabSpace.length - bestTabLength);
        tabSamples.set(sample, (tabSamples.get(sample) || 0) + 1);
    });
    let bestTabSample = '';
    for (const [sample, freq] of tabSamples){
        if (!bestTabSample || freq > tabSamples.get(bestTabSample)) bestTabSample = sample;
    }
    if (lines.length < 5 && lines.reduce((cnt, line)=>cnt + line.length, 0) < 100) bestTabSample = '  ';
    return {
        indent: indent || '',
        tab: bestTabSample
    };
}
function detectStyle(source) {
    let style = Object.assign({}, defaultStyle);
    style.newline = detectNewline(source);
    let { indent , tab  } = detectIndent$1(source, style.newline);
    style.indent = indent;
    style.tab = tab;
    let quoteMatch = source.match(/"|'/);
    if (quoteMatch) style.quote = quoteMatch[0];
    style.trailingNewline = source && source.match(new RegExp(style.newline + '$')) ? style.newline : '';
    return style;
}

function parseStyled(source, fileName) {
    // remove any byte order mark
    if (source.startsWith('\uFEFF')) source = source.substr(1);
    let style = detectStyle(source);
    try {
        return {
            json: JSON.parse(source),
            style
        };
    } catch (e) {
        throw new JspmError(`Error parsing JSON file${fileName ? ' ' + fileName : ''}`);
    }
}

let source, i;
const alwaysSelfClosing = [
    'link',
    'base'
];
function parseHtml(_source, tagNames = [
    'script',
    'link',
    'base',
    '!--'
]) {
    const scripts = [];
    source = _source;
    i = 0;
    let curScript = {
        tagName: undefined,
        start: -1,
        end: -1,
        attributes: [],
        innerStart: -1,
        innerEnd: -1
    };
    while(i < source.length){
        var ref;
        while(source.charCodeAt(i++) !== 60 /*<*/ )if (i === source.length) return scripts;
        const start = i - 1;
        const tagName = (ref = readTagName()) === null || ref === void 0 ? void 0 : ref.toLowerCase();
        if (tagName === '!--') {
            while(source.charCodeAt(i) !== 45 /*-*/  || source.charCodeAt(i + 1) !== 45 /*-*/  || source.charCodeAt(i + 2) !== 62 /*>*/ )if (++i === source.length) return scripts;
            scripts.push({
                tagName: '!--',
                start: start,
                end: i + 3,
                attributes: [],
                innerStart: start + 3,
                innerEnd: i
            });
            i += 3;
        } else if (tagName === undefined) {
            return scripts;
        } else if (tagNames.includes(tagName)) {
            curScript.tagName = tagName;
            curScript.start = i - tagName.length - 2;
            const attributes = curScript.attributes;
            let attr;
            while(attr = scanAttr())attributes.push(attr);
            let selfClosing = alwaysSelfClosing.includes(tagName);
            if (source.charCodeAt(i - 2) === 47 /*/*/  && source.charCodeAt(i - 1) === 62 /*>*/ ) selfClosing = true;
            if (selfClosing) {
                curScript.end = i;
            } else {
                curScript.innerStart = i;
                while(true){
                    while(source.charCodeAt(i++) !== 60 /*<*/ )if (i === source.length) return scripts;
                    const tag = readTagName();
                    if (tag === undefined) return scripts;
                    if (tag === '/script') {
                        curScript.innerEnd = i - 8;
                        while(scanAttr());
                        curScript.end = i;
                        break;
                    }
                }
            }
            scripts.push(curScript);
            curScript = {
                tagName: undefined,
                start: -1,
                end: -1,
                attributes: [],
                innerStart: -1,
                innerEnd: -1
            };
        } else {
            while(scanAttr());
        }
    }
    return scripts;
}
function readTagName() {
    let start = i;
    let ch;
    while(!isWs(ch = source.charCodeAt(i++)) && ch !== 62 /*>*/ )if (i === source.length) return null;
    return source.slice(start, ch === 62 ? --i : i - 1);
}
function scanAttr() {
    let ch;
    while(isWs(ch = source.charCodeAt(i)))if (++i === source.length) return null;
    if (ch === 62 /*>*/  || ch === 47 /*/*/  && (ch = source.charCodeAt(++i)) === 62 /*>*/ ) {
        i++;
        return null;
    }
    const nameStart = i;
    while(!isWs(ch = source.charCodeAt(i++)) && ch !== 61 /*=*/ ){
        if (i === source.length) return null;
        if (ch === 62 /*>*/ ) {
            if (nameStart + 2 === i && source.charCodeAt(nameStart) === 47 /*/*/ ) return null;
            return {
                nameStart,
                nameEnd: --i,
                valueStart: -1,
                valueEnd: -1
            };
        }
    }
    const nameEnd = i - 1;
    if (ch !== 61 /*=*/ ) {
        while(isWs(ch = source.charCodeAt(i)) && ch !== 61 /*=*/ ){
            if (++i === source.length) return null;
            if (ch === 62 /*>*/ ) return null;
        }
        if (ch !== 61 /*=*/ ) return {
            nameStart,
            nameEnd,
            valueStart: -1,
            valueEnd: -1
        };
    }
    while(isWs(ch = source.charCodeAt(i++))){
        if (i === source.length) return null;
        if (ch === 62 /*>*/ ) return null;
    }
    if (ch === 34 /*"*/ ) {
        const valueStart = i;
        while(source.charCodeAt(i++) !== 34 /*"*/ )if (i === source.length) return null;
        return {
            nameStart,
            nameEnd,
            valueStart,
            valueEnd: i - 1
        };
    } else if (ch === 39 /*'*/ ) {
        const valueStart1 = i;
        while(source.charCodeAt(i++) !== 39 /*'*/ )if (i === source.length) return null;
        return {
            nameStart,
            nameEnd,
            valueStart: valueStart1,
            valueEnd: i - 1
        };
    } else {
        const valueStart2 = i - 1;
        i++;
        while(!isWs(ch = source.charCodeAt(i)) && ch !== 62 /*>*/ )if (++i === source.length) return null;
        return {
            nameStart,
            nameEnd,
            valueStart: valueStart2,
            valueEnd: i
        };
    }
}
function isWs(ch) {
    return ch === 32 || ch < 14 && ch > 8;
} // function logScripts (source: string, scripts: ParsedTag[]) {
 //   for (const script of scripts) {
 //     for (const { nameStart, nameEnd, valueStart, valueEnd } of script.attributes) {
 //       console.log('Name: ' + source.slice(nameStart, nameEnd));
 //       if (valueStart !== -1)
 //         console.log('Value: ' + source.slice(valueStart, valueEnd));
 //     }
 //     console.log('"' + source.slice(script.innerStart, script.innerEnd) + '"');
 //     console.log('"' + source.slice(script.start, script.end) + '"');
 //   }
 // }

function getAttr(source, tag, name) {
    for (const attr of tag.attributes){
        if (source.slice(attr.nameStart, attr.nameEnd) === name) return source.slice(attr.valueStart, attr.valueEnd);
    }
    return null;
}
const esmsSrcRegEx = /(^|\/)(es-module-shims|esms)(\.min)?\.js$/;
function toHtmlAttrs(source, attributes) {
    return Object.fromEntries(attributes.map((attr)=>readAttr(source, attr)).map((attr)=>[
            attr.name,
            attr
        ]));
}
function analyzeHtml(source, url = baseUrl) {
    const analysis = {
        base: url,
        newlineTab: '\n',
        map: {
            json: null,
            style: null,
            start: -1,
            end: -1,
            newScript: false,
            attrs: null
        },
        staticImports: new Set(),
        dynamicImports: new Set(),
        preloads: [],
        modules: [],
        esModuleShims: null,
        comments: []
    };
    let createdInjectionPoint = false;
    const tags = parseHtml(source);
    for (const tag of tags){
        switch(tag.tagName){
            case '!--':
                analysis.comments.push({
                    start: tag.start,
                    end: tag.end,
                    attrs: {}
                });
                break;
            case 'base':
                if (!createdInjectionPoint) {
                    createInjectionPoint(source, analysis.map, tag, analysis);
                    createdInjectionPoint = true;
                }
                const href = getAttr(source, tag, 'href');
                if (href) analysis.base = new URL(href, url);
                break;
            case 'script':
                const type = getAttr(source, tag, 'type');
                if (type === 'importmap') {
                    const mapText = source.slice(tag.innerStart, tag.innerEnd);
                    const emptyMap = mapText.trim().length === 0;
                    const { json , style  } = emptyMap ? {
                        json: {},
                        style: defaultStyle
                    } : parseStyled(mapText, url.href + '#importmap');
                    const { start , end  } = tag;
                    const attrs = toHtmlAttrs(source, tag.attributes);
                    let lastChar = tag.innerEnd;
                    while(isWs(source.charCodeAt(--lastChar)));
                    analysis.newlineTab = detectIndent(source, lastChar + 1);
                    analysis.map = {
                        json,
                        style,
                        start,
                        end,
                        attrs,
                        newScript: false
                    };
                    createdInjectionPoint = true;
                } else if (type === 'module') {
                    const src = getAttr(source, tag, 'src');
                    if (src) {
                        if (esmsSrcRegEx.test(src)) {
                            analysis.esModuleShims = {
                                start: tag.start,
                                end: tag.end,
                                attrs: toHtmlAttrs(source, tag.attributes)
                            };
                        } else {
                            analysis.staticImports.add(isPlain(src) ? './' + src : src);
                            analysis.modules.push({
                                start: tag.start,
                                end: tag.end,
                                attrs: toHtmlAttrs(source, tag.attributes)
                            });
                        }
                    } else {
                        const [imports] = parse(source.slice(tag.innerStart, tag.innerEnd)) || [];
                        for (const { n , d  } of imports){
                            if (!n) continue;
                            (d === -1 ? analysis.staticImports : analysis.dynamicImports).add(n);
                        }
                    }
                } else if (!type || type === 'javascript') {
                    const src1 = getAttr(source, tag, 'src');
                    if (src1) {
                        if (esmsSrcRegEx.test(src1)) {
                            analysis.esModuleShims = {
                                start: tag.start,
                                end: tag.end,
                                attrs: toHtmlAttrs(source, tag.attributes)
                            };
                        }
                    } else {
                        const [imports1] = parse(source.slice(tag.innerStart, tag.innerEnd)) || [];
                        for (const { n: n1 , d: d1  } of imports1){
                            if (!n1) continue;
                            (d1 === -1 ? analysis.staticImports : analysis.dynamicImports).add(n1);
                        }
                    }
                }
                if (!createdInjectionPoint) {
                    createInjectionPoint(source, analysis.map, tag, analysis);
                    createdInjectionPoint = true;
                }
                break;
            case 'link':
                if (!createdInjectionPoint) {
                    createInjectionPoint(source, analysis.map, tag, analysis);
                    createdInjectionPoint = true;
                }
                if (getAttr(source, tag, 'rel') === 'modulepreload') {
                    const { start: start1 , end: end1  } = tag;
                    const attrs1 = toHtmlAttrs(source, tag.attributes);
                    analysis.preloads.push({
                        start: start1,
                        end: end1,
                        attrs: attrs1
                    });
                }
        }
    }
    if (analysis.map.start === -1) {
        createInjectionPoint(source, analysis.map, {
            tagName: 'html',
            start: source.length,
            end: source.length,
            attributes: [],
            innerStart: source.length,
            innerEnd: source.length
        }, analysis);
    }
    return analysis;
}
function createInjectionPoint(source, map, tag, analysis) {
    let lastChar = tag.innerEnd;
    while(isWs(source.charCodeAt(--lastChar)));
    analysis.newlineTab = detectIndent(source, lastChar + 1);
    if (analysis.newlineTab.indexOf('\n') === -1) {
        lastChar = tag.start;
        while(isWs(source.charCodeAt(--lastChar)));
        analysis.newlineTab = detectIndent(source, lastChar + 1);
    }
    map.newScript = true;
    map.attrs = toHtmlAttrs(source, tag.attributes);
    map.start = map.end = tag.start;
}
function readAttr(source, { nameStart , nameEnd , valueStart , valueEnd  }) {
    return {
        start: nameStart,
        end: valueEnd !== -1 ? valueEnd : nameEnd,
        quote: valueStart !== -1 && (source[valueStart - 1] === '"' || source[valueStart - 1] === "'") ? source[valueStart - 1] : '',
        name: source.slice(nameStart, nameEnd),
        value: valueStart === -1 ? null : source.slice(valueStart, valueEnd)
    };
}
function detectIndent(source, atIndex) {
    if (source === '' || atIndex === -1) return '';
    const nlIndex = atIndex;
    if (source[atIndex] === '\r' && source[atIndex + 1] === '\n') atIndex++;
    if (source[atIndex] === '\n') atIndex++;
    while(source[atIndex] === ' ' || source[atIndex] === '\t')atIndex++;
    return source.slice(nlIndex, atIndex) || '';
}

const wsRegEx = /^\s+/;
class Replacer {
    replace(start, end, replacement) {
        const startOffset = findOffset(this.offsetTable, start);
        const endOffset = findOffset(this.offsetTable, end);
        this.source = this.source.slice(0, start + startOffset) + replacement + this.source.slice(end + endOffset);
        addOffset(this.offsetTable, end, replacement.length - (end + endOffset - start - startOffset));
    }
    remove(start, end, trimWs = false) {
        this.replace(start, end, '');
        if (trimWs) {
            if (typeof trimWs === 'boolean') trimWs = wsRegEx;
            const endIndex = this.idx(end);
            var ref;
            const [wsMatch] = (ref = this.source.slice(endIndex).match(trimWs)) !== null && ref !== void 0 ? ref : [];
            var ref1;
            this.source = this.source.slice(0, endIndex) + this.source.slice((ref1 = endIndex + (wsMatch === null || wsMatch === void 0 ? void 0 : wsMatch.length)) !== null && ref1 !== void 0 ? ref1 : 0);
            var ref2;
            addOffset(this.offsetTable, end, (ref2 = -(wsMatch === null || wsMatch === void 0 ? void 0 : wsMatch.length)) !== null && ref2 !== void 0 ? ref2 : 0);
        }
    }
    idx(idx) {
        return idx + findOffset(this.offsetTable, idx);
    }
    constructor(source){
        this.offsetTable = [];
        this.source = source;
    }
}
function addOffset(offsetTable, idx, offset) {
    let i = offsetTable.length, eq = false;
    while(i-- > 0){
        const [offsetIdx] = offsetTable[i];
        if (offsetIdx < idx || offsetIdx === idx && (eq = true)) break;
    }
    if (eq) offsetTable.splice(i, 1, [
        idx,
        offset + offsetTable[i][1]
    ]);
    else offsetTable.splice(i + 1, 0, [
        idx,
        offset
    ]);
}
function findOffset(offsetTable, idx) {
    let curOffset = 0;
    for (const [offsetIdx, offset] of offsetTable){
        if (offsetIdx > idx) break;
        curOffset += offset;
    }
    return curOffset;
}

/**
 * Supports clearing the global fetch cache in Node.js.
 * 
 * Example:
 * 
 * ```js
 * import { clearCache } from '@jspm/generator';
 * clearCache();
 * ```
 */ function clearCache() {
    clearCache$1();
}
class Generator {
    /**
   * Add new custom mappings and lock resolutions to the input map
   * of the generator, which are then applied in subsequent installs.
   * 
   * @param jsonOrHtml The mappings are parsed as JSON data object or string, falling
   * back to reading an inline import map from an HTML file.
   * @param mapUrl An optional URL for the map to handle relative resolutions, defaults to generator mapUrl
   * @param rootUrl An optional root URL for the map to handle root resolutions, defaults to generator rootUrl
   * @returns The list of modules pinned by this import map or HTML
   * 
   */ async addMappings(jsonOrHtml, mapUrl = this.mapUrl, rootUrl = this.rootUrl, preloads) {
        if (typeof mapUrl === 'string') mapUrl = new URL(mapUrl, this.baseUrl);
        if (typeof rootUrl === 'string') rootUrl = new URL(rootUrl, this.baseUrl);
        let htmlModules;
        if (typeof jsonOrHtml === 'string') {
            try {
                jsonOrHtml = JSON.parse(jsonOrHtml);
            } catch  {
                const analysis = analyzeHtml(jsonOrHtml, mapUrl);
                jsonOrHtml = analysis.map.json || {};
                preloads = (preloads || []).concat(analysis.preloads.map((preload)=>{
                    var ref;
                    return (ref = preload.attrs.href) === null || ref === void 0 ? void 0 : ref.value;
                }).filter((x)=>x));
                htmlModules = [
                    ...new Set([
                        ...analysis.staticImports,
                        ...analysis.dynamicImports
                    ])
                ];
            }
        }
        await this.traceMap.addInputMap(jsonOrHtml, mapUrl, rootUrl, preloads);
        return htmlModules || [
            ...this.traceMap.pins
        ];
    }
    /**
   * Retrieve the lockfile data from the installer
   */ getLock() {
        return JSON.parse(JSON.stringify(this.traceMap.installer.installs));
    }
    /**
   * Trace and pin a module, installing all dependencies necessary into the map
   * to support its execution including static and dynamic module imports.
   * 
   * @deprecated Use "traceInstall" instead.
   */ async pin(specifier, parentUrl) {
        return this.traceInstall(specifier, parentUrl);
    }
    /**
   * Trace a module, installing all dependencies necessary into the map
   * to support its execution including static and dynamic module imports.
   * 
   * @param specifier Module to trace
   * @param parentUrl Optional parent URL
   */ async traceInstall(specifier, parentUrl) {
        if (typeof specifier === 'string') specifier = [
            specifier
        ];
        let error = false;
        if (this.installCnt++ === 0) this.traceMap.startInstall();
        specifier = specifier.map((specifier)=>specifier.replace(/\\/g, '/'));
        await this.traceMap.processInputMap;
        try {
            await Promise.all(specifier.map((specifier)=>this.traceMap.visit(specifier, {
                    mode: 'new',
                    toplevel: true
                }, parentUrl || this.mapUrl.href)));
            for (const s of specifier){
                if (!this.traceMap.pins.includes(s)) this.traceMap.pins.push(s);
            }
        } catch (e) {
            error = true;
            throw e;
        } finally{
            if (--this.installCnt === 0) {
                const { map , staticDeps , dynamicDeps  } = await this.traceMap.finishInstall();
                this.map = map;
                if (!error) return {
                    staticDeps,
                    dynamicDeps
                };
            }
        }
    }
    /**
   * Generate and inject an import map for an HTML file
   * 
   * @deprecated Instead use:
   *   const pins = await generator.addMappings(html, mapUrl, rootUrl);
   *   return await generator.htmlInject(html, { pins, htmlUrl: mapUrl, rootUrl, preload, integrity, whitespace, esModuleShims, comment });
   *
   * Traces the module scripts of the HTML via traceInstall and install
   * for URL-like specifiers and bare specifiers respectively.
   * 
   * Injects the final generated import map returning the injected HTML
   * 
   * @param html String
   * @param injectOptions Injection options
   * 
   * Injection options are: `htmlUrl`, `preload`, `integrity`, `whitespace`
   * and `esModuleShims`. The default is `{ esModuleShims: true, whitespace: true }`.
   * 
   * ES Module shims will be resolved to the latest version against the provider
   * 
   * Example:
   * 
   * ```js
   *  const outputHtml = await generator.htmlGenerate(`
   *    <!doctype html>
   *    <script type="module">import 'react'</script>
   *  `);
   * ```
   * 
   * which outputs:
   * 
   * ```
   *   <!doctype html>
   *   <!-- Generated by @jspm/generator - https://github.com/jspm/generator -->
   *   <script async src="https://ga.jspm.io/npm:es-module-shims@1.4.1/dist/es-module-shims.js"></script>
   *   <script type="importmap">
   *   {...}
   *   </script>
   *   <script type="module">import 'react'</script>
   * ```
   * 
   */ async htmlGenerate(html, { mapUrl , rootUrl , preload =false , integrity =false , whitespace =true , esModuleShims =true , comment =true  } = {}) {
        if (typeof mapUrl === 'string') mapUrl = new URL(mapUrl);
        const pins = await this.addMappings(html, mapUrl, rootUrl);
        return await this.htmlInject(html, {
            pins,
            htmlUrl: mapUrl,
            rootUrl,
            preload,
            integrity,
            whitespace,
            esModuleShims,
            comment
        });
    }
    /**
   * Inject the import map into the provided HTML source
   * 
   * @param html HTML source to inject into
   * @param opts Injection options
   * @returns HTML source with import map injection
   */ async htmlInject(html, { trace =false , pins =!trace , htmlUrl , rootUrl , preload =false , integrity =false , whitespace =true , esModuleShims =true , comment =true  } = {}) {
        if (comment === true) comment = ' Generated by @jspm/generator - https://github.com/jspm/generator ';
        if (typeof htmlUrl === 'string') htmlUrl = new URL(htmlUrl);
        if (integrity) preload = true;
        if (this.installCnt !== 0) throw new JspmError('htmlGenerate cannot run alongside other install ops');
        const analysis = analyzeHtml(html, htmlUrl);
        let modules = pins === true ? this.traceMap.pins : Array.isArray(pins) ? pins : [];
        if (trace) {
            const impts = [
                ...new Set([
                    ...analysis.staticImports,
                    ...analysis.dynamicImports
                ])
            ];
            await Promise.all(impts.map((impt)=>this.traceInstall(impt)));
            modules = [
                ...new Set([
                    ...modules,
                    ...impts
                ])
            ];
        }
        const { map , staticDeps , dynamicDeps  } = await this.extractMap(modules, htmlUrl, rootUrl);
        const preloadDeps = preload === true && integrity || preload === 'all' ? [
            ...new Set([
                ...staticDeps,
                ...dynamicDeps
            ])
        ] : staticDeps;
        const newlineTab = !whitespace ? analysis.newlineTab : analysis.newlineTab.includes('\n') ? analysis.newlineTab : '\n' + analysis.newlineTab;
        const replacer = new Replacer(html);
        let esms = '';
        if (esModuleShims) {
            const esmsPkg = await this.traceMap.resolver.resolveLatestTarget({
                name: 'es-module-shims',
                registry: 'npm',
                ranges: [
                    new SemverRange$2('*')
                ],
                unstable: false
            }, this.traceMap.installer.defaultProvider);
            const esmsUrl = this.traceMap.resolver.pkgToUrl(esmsPkg, this.traceMap.installer.defaultProvider) + 'dist/es-module-shims.js';
            esms = `<script async src="${esmsUrl}" crossorigin="anonymous"${integrity ? ` integrity="${await getIntegrity(esmsUrl, this.traceMap.resolver.fetchOpts)}"` : ''}></script>${newlineTab}`;
            if (analysis.esModuleShims) replacer.remove(analysis.esModuleShims.start, analysis.esModuleShims.end, true);
        }
        for (const preload1 of analysis.preloads){
            replacer.remove(preload1.start, preload1.end, true);
        }
        let preloads = '';
        if (preload && preloadDeps.length) {
            let first = true;
            for (let dep of preloadDeps.sort()){
                if (first || whitespace) preloads += newlineTab;
                if (first) first = false;
                if (integrity) {
                    preloads += `<link rel="modulepreload" href="${relativeUrl(new URL(dep), this.rootUrl || this.baseUrl, !!this.rootUrl)}" integrity="${await getIntegrity(dep, this.traceMap.resolver.fetchOpts)}" />`;
                } else {
                    preloads += `<link rel="modulepreload" href="${relativeUrl(new URL(dep), this.rootUrl || this.baseUrl, !!this.rootUrl)}" />`;
                }
            }
        }
        // when applying integrity, all existing script tags have their integrity updated
        if (integrity) {
            for (const module of analysis.modules){
                if (!module.attrs.src) continue;
                if (module.attrs.integrity) {
                    replacer.remove(module.attrs.integrity.start - (replacer.source[replacer.idx(module.attrs.integrity.start - 1)] === ' ' ? 1 : 0), module.attrs.integrity.end + 1);
                }
                const lastAttr = Object.keys(module.attrs).filter((attr)=>attr !== 'integrity').sort((a, b)=>module.attrs[a].end > module.attrs[b].end ? -1 : 1)[0];
                replacer.replace(module.attrs[lastAttr].end + 1, module.attrs[lastAttr].end + 1, ` integrity="${await getIntegrity(resolveUrl(module.attrs.src.value, this.mapUrl, this.rootUrl), this.traceMap.resolver.fetchOpts)}"`);
            }
        }
        if (comment) {
            const existingComment = analysis.comments.find((c)=>replacer.source.slice(replacer.idx(c.start), replacer.idx(c.end)).includes(comment));
            if (existingComment) {
                replacer.remove(existingComment.start, existingComment.end, true);
            }
        }
        replacer.replace(analysis.map.start, analysis.map.end, (comment ? '<!--' + comment + '-->' + newlineTab : '') + esms + '<script type="importmap">' + (whitespace ? newlineTab : '') + JSON.stringify(map, null, whitespace ? 2 : 0).replace(/\n/g, newlineTab) + (whitespace ? newlineTab : '') + '</script>' + preloads + (analysis.map.newScript ? newlineTab : ''));
        return replacer.source;
    }
    /**
   * Install a package target into the import map, including all its dependency resolutions via tracing.
   * @param install Package to install
   * 
   * For example:
   * 
   * ```js
   * // Install a new package into the import map
   * await generator.install('react-dom');
   * 
   * // Install a package version and subpath into the import map (installs lit/decorators.js)
   * await generator.install('lit@2/decorators.js');
   * 
   * // Install a package version to a custom alias
   * await generator.install({ alias: 'react16', target: 'react@16' });
   * 
   * // Install a specific subpath of a package
   * await generator.install({ target: 'lit@2', subpath: './html.js' });
   * 
   * // Install an export from a locally located package folder into the map
   * // The package.json is used to determine the exports and dependencies.
   * await generator.install({ alias: 'mypkg', target: './packages/local-pkg', subpath: './feature' });
   * ```
   * 
   */ async install(install) {
        if (Array.isArray(install)) return await Promise.all(install.map((install)=>this.install(install))).then((installs)=>installs.find((i)=>i));
        if (arguments.length !== 1) throw new Error('Install takes a single target string or object.');
        if (typeof install !== 'string' && install.subpaths !== undefined) {
            install.subpaths.every((subpath)=>{
                if (typeof subpath !== 'string' || subpath !== '.' && !subpath.startsWith('./')) throw new Error(`Install subpath "${subpath}" must be equal to "." or start with "./".`);
            });
            return await Promise.all(install.subpaths.map((subpath)=>this.install({
                    target: install.target,
                    alias: install.alias,
                    subpath
                }))).then((installs)=>installs.find((i)=>i));
        }
        let error = false;
        if (this.installCnt++ === 0) this.traceMap.startInstall();
        await this.traceMap.processInputMap;
        try {
            let alias, target, subpath;
            if (typeof install === 'string' || typeof install.target === 'string') {
                ({ alias , target , subpath  } = await installToTarget.call(this, install, this.traceMap.installer.defaultRegistry));
            } else {
                ({ alias , target , subpath  } = install);
                validatePkgName(alias);
            }
            await this.traceMap.add(alias, target);
            await this.traceMap.visit(alias + subpath.slice(1), {
                mode: 'new',
                toplevel: true
            }, this.mapUrl.href);
            if (!this.traceMap.pins.includes(alias + subpath.slice(1))) this.traceMap.pins.push(alias + subpath.slice(1));
        } catch (e) {
            error = true;
            throw e;
        } finally{
            if (--this.installCnt === 0) {
                const { map , staticDeps , dynamicDeps  } = await this.traceMap.finishInstall();
                this.map = map;
                if (!error) return {
                    staticDeps,
                    dynamicDeps
                };
            }
        }
    }
    async reinstall() {
        if (this.installCnt++ === 0) this.traceMap.startInstall();
        await this.traceMap.processInputMap;
        if (--this.installCnt === 0) {
            const { map , staticDeps , dynamicDeps  } = await this.traceMap.finishInstall();
            this.map = map;
            return {
                staticDeps,
                dynamicDeps
            };
        }
    }
    async update(pkgNames) {
        if (typeof pkgNames === 'string') pkgNames = [
            pkgNames
        ];
        if (this.installCnt++ === 0) this.traceMap.startInstall();
        await this.traceMap.processInputMap;
        const primaryResolutions = this.traceMap.installer.installs.primary;
        const primaryConstraints = this.traceMap.installer.constraints.primary;
        if (!pkgNames) pkgNames = Object.keys(primaryResolutions);
        const installs = [];
        for (const name of pkgNames){
            const resolution = primaryResolutions[name];
            if (!resolution) {
                this.installCnt--;
                throw new JspmError(`No "imports" package entry for "${name}" to update. Note update takes package names not package specifiers.`);
            }
            const { installUrl , installSubpath  } = resolution;
            const subpaths = this.traceMap.pins.filter((pin)=>pin === name || pin.startsWith(name) && pin[name.length] === '/').map((pin)=>`.${pin.slice(name.length)}`);
            // use package.json range if present
            if (primaryConstraints[name]) {
                installs.push({
                    alias: name,
                    subpaths,
                    target: {
                        pkgTarget: primaryConstraints[name],
                        installSubpath
                    }
                });
            } else {
                const pkg = this.traceMap.resolver.parseUrlPkg(installUrl);
                if (!pkg) throw new Error(`Unable to determine a package version lookup for ${name}. Make sure it is supported as a provider package.`);
                const target = {
                    pkgTarget: {
                        registry: pkg.pkg.registry,
                        name: pkg.pkg.name,
                        ranges: [
                            new SemverRange$2('^' + pkg.pkg.version)
                        ],
                        unstable: false
                    },
                    installSubpath
                };
                installs.push({
                    alias: name,
                    subpaths,
                    target
                });
            }
        }
        await this.install(installs);
        if (--this.installCnt === 0) {
            const { map , staticDeps , dynamicDeps  } = await this.traceMap.finishInstall();
            this.map = map;
            return {
                staticDeps,
                dynamicDeps
            };
        }
    }
    async uninstall(names) {
        if (typeof names === 'string') names = [
            names
        ];
        if (this.installCnt++ === 0) this.traceMap.startInstall();
        await this.traceMap.processInputMap;
        let pins = this.traceMap.pins;
        const unusedNames = new Set([
            ...names
        ]);
        for(let i = 0; i < pins.length; i++){
            const pin = pins[i];
            const pinNames = names.filter((name)=>name === pin || name.endsWith('/') && pin.startsWith(name));
            if (pinNames.length) {
                pins.splice(i--, 1);
                for (const name of pinNames)unusedNames.delete(name);
            }
        }
        if (unusedNames.size) {
            this.installCnt--;
            throw new JspmError(`No "imports" entry for "${[
                ...unusedNames
            ][0]}" to uninstall.`);
        }
        this.traceMap.pins = pins;
        if (--this.installCnt === 0) {
            const { map  } = await this.traceMap.finishInstall();
            this.map = map;
        }
    }
    async extractMap(pins, mapUrl, rootUrl) {
        if (typeof mapUrl === 'string') mapUrl = new URL(mapUrl, this.baseUrl);
        if (typeof rootUrl === 'string') rootUrl = new URL(rootUrl, this.baseUrl);
        if (!Array.isArray(pins)) pins = [
            pins
        ];
        if (this.installCnt++ !== 0) throw new JspmError(`Cannot run extract map during installs`);
        this.traceMap.startInstall();
        await this.traceMap.processInputMap;
        if (--this.installCnt !== 0) throw new JspmError(`Another install was started during extract map.`);
        const { map , staticDeps , dynamicDeps  } = await this.traceMap.finishInstall(pins);
        map.rebase(mapUrl, rootUrl);
        map.flatten();
        map.sort();
        map.combineSubpaths();
        return {
            map: map.toJSON(),
            staticDeps,
            dynamicDeps
        };
    }
    /**
   * Resolve a specifier using the import map.
   * 
   * @param specifier Module to resolve
   * @param parentUrl ParentURL of module to resolve
   * @returns Resolved URL string
   */ resolve(specifier, parentUrl = this.baseUrl) {
        if (typeof parentUrl === 'string') parentUrl = new URL(parentUrl, this.baseUrl);
        const resolved = this.map.resolve(specifier, parentUrl);
        if (resolved === null) throw new JspmError(`Unable to resolve "${specifier}" from ${parentUrl.href}`, 'MODULE_NOT_FOUND');
        return resolved;
    }
    /**
   * Get the import map JSON
   */ get importMap() {
        return this.map;
    }
    /**
   * 
   * @param url 
   * @returns 
   */ getAnalysis(url) {
        if (typeof url !== 'string') url = url.href;
        const trace = this.traceMap.tracedUrls[url];
        if (!trace) throw new Error(`The URL ${url} has not been traced by this generator instance.`);
        return {
            format: trace.format,
            staticDeps: trace.deps,
            dynamicDeps: trace.dynamicDeps,
            cjsLazyDeps: trace.cjsLazyDeps || []
        };
    }
    getMap(mapUrl, rootUrl) {
        const map = this.map.clone();
        map.rebase(mapUrl, rootUrl);
        map.flatten();
        map.sort();
        map.combineSubpaths();
        return map.toJSON();
    }
    /**
   * @param options GeneratorOptions
   * 
   * For example:
   * 
   * ```js
   * const generator = new Generator({
   *   mapUrl: import.meta.url,
   *   inputMap: {
   *     "imports": {
   *       "react": "https://cdn.skypack.dev/react"
   *     }
   *   },
   *   defaultProvider: 'jspm',
   *   defaultRegistry: 'npm',
   *   providers: {
   *     '@orgscope': 'nodemodules'
   *   },
   *   customProviders: {},
   *   env: ['production', 'browser'],
   *   cache: false,
   * });
   * ```
   */ constructor({ baseUrl: baseUrl$1 , mapUrl , rootUrl =undefined , inputMap =undefined , env =[
        'browser',
        'development',
        'module',
        'import'
    ] , defaultProvider ='jspm' , defaultRegistry ='npm' , customProviders =undefined , providers , resolutions ={} , cache =true , ignore =[] , freeze , latest , ipfsAPI  } = {}){
        this.installCnt = 0;
        let fetchOpts = undefined;
        if (cache === 'offline') fetchOpts = {
            cache: 'force-cache',
            headers: {
                'Accept-Encoding': 'gzip, br'
            }
        };
        else if (!cache) fetchOpts = {
            cache: 'no-store',
            headers: {
                'Accept-Encoding': 'gzip, br'
            }
        };
        else fetchOpts = {
            headers: {
                'Accept-Encoding': 'gzip, br'
            }
        };
        if (ipfsAPI) fetchOpts.ipfsAPI = ipfsAPI;
        const { log , logStream  } = createLogger();
        const resolver = new Resolver(env, log, fetchOpts, true);
        if (customProviders) {
            for (const provider of Object.keys(customProviders)){
                resolver.addCustomProvider(provider, customProviders[provider]);
            }
        }
        this.logStream = logStream;
        if (process$1.env.JSPM_GENERATOR_LOG) {
            (async ()=>{
                for await (const { type , message  } of this.logStream()){
                    console.log(type, message);
                }
            })();
        }
        if (mapUrl && !baseUrl$1) {
            mapUrl = typeof mapUrl === 'string' ? new URL(mapUrl, baseUrl) : mapUrl;
            try {
                baseUrl$1 = new URL('./', mapUrl);
            } catch  {
                baseUrl$1 = new URL(mapUrl + '/');
            }
        } else if (baseUrl$1 && !mapUrl) {
            mapUrl = baseUrl$1;
        } else if (!mapUrl && !baseUrl$1) {
            baseUrl$1 = mapUrl = baseUrl;
        }
        this.baseUrl = typeof baseUrl$1 === 'string' ? new URL(baseUrl$1, baseUrl) : baseUrl$1;
        if (!this.baseUrl.pathname.endsWith('/')) {
            this.baseUrl = new URL(this.baseUrl.href);
            this.baseUrl.pathname += '/';
        }
        this.mapUrl = typeof mapUrl === 'string' ? new URL(mapUrl, this.baseUrl) : mapUrl;
        this.rootUrl = typeof rootUrl === 'string' ? new URL(rootUrl, this.baseUrl) : rootUrl || null;
        if (this.rootUrl && !this.rootUrl.pathname.endsWith('/')) this.rootUrl.pathname += '/';
        if (!this.mapUrl.pathname.endsWith('/')) {
            try {
                this.mapUrl = new URL('./', this.mapUrl);
            } catch  {
                this.mapUrl = new URL(this.mapUrl.href + '/');
            }
        }
        this.traceMap = new TraceMap({
            mapUrl: this.mapUrl,
            rootUrl: this.rootUrl,
            baseUrl: this.baseUrl,
            defaultProvider,
            defaultRegistry,
            providers,
            ignore,
            resolutions,
            freeze,
            latest
        }, log, resolver);
        this.map = new ImportMap({
            mapUrl: this.mapUrl,
            rootUrl: this.rootUrl
        });
        if (inputMap) this.addMappings(inputMap);
    }
}
/**
 * _Use the internal fetch implementation, useful for hooking into the same shared local fetch cache._
 * 
 * ```js
 * import { fetch } from '@jspm/generator';
 * 
 * const res = await fetch(url);
 * console.log(await res.text());
 * ```
 * 
 * Use the `{ cache: 'no-store' }` option to disable the cache, and the `{ cache: 'force-cache' }` option to enforce the offline cache.
 */ async function fetch(url, opts = {}) {
    // @ts-ignore
    return fetch$1(url, opts);
}
/**
 * Get the lookup resolution information for a specific install.
 * 
 * @param install The install object
 * @param lookupOptions Provider and cache defaults for lookup
 * @returns The resolved install and exact package { install, resolved }
 */ async function lookup(install, { provider , cache  } = {}) {
    const generator = new Generator({
        cache: !cache,
        defaultProvider: provider
    });
    const { target: { pkgTarget , installSubpath  } , subpath , alias  } = await installToTarget.call(generator, install, generator.traceMap.installer.defaultRegistry);
    if (pkgTarget instanceof URL) throw new Error('URL lookups not supported');
    const resolved = await generator.traceMap.resolver.resolveLatestTarget(pkgTarget, generator.traceMap.installer.getProvider(pkgTarget));
    return {
        install: {
            target: {
                registry: pkgTarget.registry,
                name: pkgTarget.name,
                range: pkgTarget.ranges.map((range)=>range.toString()).join(' || ')
            },
            installSubpath,
            subpath,
            alias
        },
        resolved: resolved
    };
}
/**
 * Get the package.json configuration for a specific URL or package.
 * 
 * @param pkg Package to lookup configuration for
 * @param lookupOptions Optional provider and cache defaults for lookup
 * @returns Package JSON configuration
 * 
 * Example:
 * ```js
 * import { getPackageConfig } from '@jspm/generator';
 * 
 * // Supports a resolved package
 * {
 *   const packageJson = await getPackageConfig({ registry: 'npm', name: 'lit-element', version: '2.5.1' });
 * }
 * 
 * // Or alternatively provide any URL
 * {
 *   const packageJson = await getPackageConfig('https://ga.jspm.io/npm:lit-element@2.5.1/lit-element.js');
 * }
 * ```
 */ async function getPackageConfig(pkg, { provider , cache  } = {}) {
    const generator = new Generator({
        cache: !cache,
        defaultProvider: provider
    });
    if (typeof pkg === 'object' && 'name' in pkg) pkg = generator.traceMap.resolver.pkgToUrl(pkg, generator.traceMap.installer.defaultProvider);
    else if (typeof pkg === 'string') pkg = new URL(pkg).href;
    else pkg = pkg.href;
    return generator.traceMap.resolver.getPackageConfig(pkg);
}
/**
 * Get the package base URL for the given module URL.
 * 
 * @param url module URL
 * @param lookupOptions Optional provider and cache defaults for lookup
 * @returns Base package URL
 * 
 * Modules can be remote CDN URLs or local file:/// URLs.
 * 
 * All modules in JSPM are resolved as within a package boundary, which is the
 * parent path of the package containing a package.json file.
 * 
 * For JSPM CDN this will always be the base of the package as defined by the
 * JSPM CDN provider. For non-provider-defined origins it is always determined
 * by trying to fetch the package.json in each parent path until the root is reached
 * or one is found. On file:/// URLs this exactly matches the Node.js resolution
 * algorithm boundary lookup.
 * 
 * This package.json file controls the package name, imports resolution, dependency
 * resolutions and other package information.
 * 
 * getPackageBase will return the folder containing the package.json,
 * with a trailing '/'.
 * 
 * This URL will either be the root URL of the origin, or it will be a
 * path "pkgBase" such that fetch(`${pkgBase}package.json`) is an existing
 * package.json file.
 * 
 * For example:
 * 
 * ```js
 *   import { getPackageBase } from '@jspm/generator'; 
 *   const pkgUrl = await getPackageBase('https://ga.jspm.io/npm:lit-element@2.5.1/lit-element.js');
 *   // Returns: https://ga.jspm.io/npm:lit-element@2.5.1/
 * ```
 */ async function getPackageBase(url, { provider , cache  } = {}) {
    const generator = new Generator({
        cache: !cache,
        defaultProvider: provider
    });
    return generator.traceMap.resolver.getPackageBase(typeof url === 'string' ? url : url.href);
}
async function installToTarget(install, defaultRegistry) {
    if (typeof install === 'string') install = {
        target: install
    };
    if (typeof install.target !== 'string') throw new Error('All installs require a "target" string.');
    if (install.subpath !== undefined && (typeof install.subpath !== 'string' || install.subpath !== '.' && !install.subpath.startsWith('./'))) throw new Error(`Install subpath "${install.subpath}" must be a string equal to "." or starting with "./".${typeof install.subpath === 'string' ? `\nTry setting the subpath to "./${install.subpath}"` : ''}`);
    const { alias , target , subpath  } = await toPackageTarget(this.traceMap.resolver, install.target, this.baseUrl, defaultRegistry);
    return {
        target,
        alias: install.alias || alias,
        subpath: install.subpath || subpath
    };
}

export { Generator as G, setPathFns as a, setBabel$1 as b, setBabel as c, analyzeHtml as d, clearCache as e, fetch as f, getPackageConfig as g, getPackageBase as h, lookup as l, setCreateHash as s };
