local lspconfig = require 'lspconfig'

lspconfig.ols.setup {
  init_options = {
    checker_args = '-strict-style',
    collection = {
      { name = 'shared', path = vim.fn.expand '$ODIN_ROOT' },
    },
  },
}

local gdscript_config = {
  name = 'gdscript',
  cmd = { 'socat', 'stdio', 'tcp:localhost:6005' },
  filetypes = { 'gdscript' },
  root_dir = lspconfig.util.root_pattern('project.godot', '.git'),
  capabilities = { textDocument = { completion = { completionItem = { snippetSupport = false } } } },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gdscript',
  callback = function()
    vim.lsp.start(gdscript_config)
  end,
})

local cfg = {
  configurations = {
    odin = {
      {
        name = 'Debug Odin',
        type = 'lldb',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = function()
          local out_drop = vim.fn.system { 'mkdir', '-p', 'build' }
          local out = vim.fn.system { 'odin', 'build', '.', '-out:build/raw', '-debug' }
          if vim.v.shell_error ~= 0 then
            vim.notify(out_drop, vim.log.levels.ERROR)
            vim.notify(out, vim.log.levels.ERROR)
            return nil
          end
          return 'build/raw'
        end,
        stopOnEntry = false,
        args = {},
      },
    },
    cpp = {
      name = 'Debug Godot Editor',
      type = 'lldb',
      request = 'launch',
      program = '${workspaceFolder}/bin/godot.linuxbsd.editor.x86_64',
      args = {},
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      runInTerminal = false,
      env = {
        GODOT_DEBUG = '1',
      },
    },
  },
}

require('dap-lldb').setup(cfg)
--[[
local debugger = vim.fn.exepath 'lldb'
if debugger ~= '' then
  dap.adapters.lldb = {
    type = 'executable',
    command = debugger,
  }
  dap.configurations.lldb = {
    {
      type = 'lldb',
      name = 'debug',
      task = 'build/raw',
      request = 'launch',
      program = '${workspaceFolder}/build/raw',
      exitAfterTaskReturns = false,
      debugAutoInterpretAllModules = false,
    },
  }
end
--]]
