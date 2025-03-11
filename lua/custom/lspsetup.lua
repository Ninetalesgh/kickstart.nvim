local lspconfig = require 'lspconfig'

lspconfig.ols.setup {
  cmd = { 'ols' },
  filetypes = { 'odin' },
  root_dir = lspconfig.util.root_pattern('ols.json', '.git', 'odin.mod'),
}
