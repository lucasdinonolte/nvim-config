--- Prerequisites
--- npm install -g cssmodules-language-server
return {
  cmd = { 'cssmodules-language-server' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'package.json' },
}
